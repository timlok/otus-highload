# - Try to find the PostgreSQL libraries
#
#  POSTGRESQL_INCLUDE_DIR - PostgreSQL include directory
#  POSTGRESQL_LIBRARY     - PostgreSQL library
#  PQ_LIBRARY             - PostgreSQL PQ library

find_path(
    POSTGRESQL_INCLUDE_DIR
    NAMES common/base64.h common/saslprep.h common/scram-common.h common/sha2.h
    PATH_SUFFIXES pgsql-11/include/server
)

find_library(
    POSTGRESQL_LIBRARY
    NAMES pgcommon
    HINTS "/usr/pgsql-11/include/server/"
    PATH_SUFFIXES pgsql-11/lib/
)

find_library(
    PQ_LIBRARY
    NAMES libpq.a
    PATH_SUFFIXES pgsql-11/lib/
)

find_package_handle_standard_args(
    POSTGRESQL
    REQUIRED_VARS POSTGRESQL_LIBRARY PQ_LIBRARY POSTGRESQL_INCLUDE_DIR
)
