/*
 * RHQ Management Platform
 * Copyright 2013, Red Hat Middleware LLC, and individual contributors
 * as indicated by the @author tags. See the copyright.txt file in the
 * distribution for a full listing of individual contributors.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation version 2 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

package org.rhq.server.metrics.migrator.workers;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.StatelessSession;

import org.rhq.server.metrics.migrator.DataMigrator;
import org.rhq.server.metrics.migrator.DataMigrator.DataMigratorConfiguration;
import org.rhq.server.metrics.migrator.DataMigrator.DatabaseType;
import org.rhq.server.metrics.migrator.DataMigrator.Task;
import org.rhq.server.metrics.migrator.datasources.ExistingDataSource;
import org.rhq.server.metrics.migrator.datasources.ExistingPostgresDataBulkExportSource;
import org.rhq.server.metrics.migrator.datasources.ScrollableDataSource;

/**
 * @author Stefan Negrea
 *
 */
public abstract class AbstractMigrationWorker {
    private final Log log = LogFactory.getLog(AbstractMigrationWorker.class);

    /**
     * Returns a list of all the raw SQL metric tables.
     * There is no equivalent in Cassandra, all raw data is stored in a single column family.
     *
     * @return SQL raw metric tables
     */
    protected static String[] getRawDataTables() {
        int tableCount = 15;
        String tablePrefix = "RHQ_MEAS_DATA_NUM_R";

        String[] tables = new String[tableCount];
        for (int i = 0; i < tableCount; i++) {
            if (i < 10) {
                tables[i] = tablePrefix + "0" + i;
            } else {
                tables[i] = tablePrefix + i;
            }
        }

        return tables;
    }

    protected ExistingDataSource getExistingDataSource(String query, Task task, DataMigratorConfiguration config) {
        if (Task.Migrate.equals(task)) {
            if (DatabaseType.Oracle.equals(config.getDatabaseType())) {
                return new ScrollableDataSource(config.getEntityManager(), config.getDatabaseType(), query);
            } else {
                if (!config.isExperimentalDataSource()) {
                    return new ScrollableDataSource(config.getEntityManager(), config.getDatabaseType(), query);
                } else {
                    return new ExistingPostgresDataBulkExportSource(config.getEntityManager(), query);
                }
            }
        } else if (Task.Estimate.equals(task)) {
            int limit = CallableMigrationWorker.MAX_RECORDS_TO_LOAD_FROM_SQL
                * (CallableMigrationWorker.NUMBER_OF_BATCHES_FOR_ESTIMATION + 1);

            if (DatabaseType.Oracle.equals(config.getDatabaseType())) {
                return new ScrollableDataSource(config.getEntityManager(), config.getDatabaseType(), query, limit);
            } else {
                if (!config.isExperimentalDataSource()) {
                    return new ScrollableDataSource(config.getEntityManager(), config.getDatabaseType(), query, limit);
                } else {
                    return new ExistingPostgresDataBulkExportSource(config.getEntityManager(), query, limit);
                }
            }
        }

        return new ScrollableDataSource(config.getEntityManager(), config.getDatabaseType(), query);
    }

    protected void prepareSQLSession(StatelessSession session, DataMigratorConfiguration config) {
        if (DatabaseType.Postgres.equals(config.getDatabaseType())) {
            log.debug("Preparing SQL connection with timeout: " + DataMigrator.SQL_TIMEOUT);

            org.hibernate.Query query = session.createSQLQuery("SET LOCAL statement_timeout = "
                + DataMigrator.SQL_TIMEOUT);
            query.setReadOnly(true);
            query.executeUpdate();
        }
    }

    protected StatelessSession getSQLSession(DataMigratorConfiguration config) {
        StatelessSession session = ((org.hibernate.Session) config.getEntityManager().getDelegate())
            .getSessionFactory().openStatelessSession();

        prepareSQLSession(session, config);

        return session;
    }

    protected void closeSQLSession(StatelessSession session) {
        try {
            if (session != null) {
                session.close();
            }
        } catch (Exception e) {
            //log.debug("Unable to close SQL stateless session. " + e);
        }
    }

}
