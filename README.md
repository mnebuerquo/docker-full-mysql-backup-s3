# This is a fork, for reasons:

1. [Not compatible with newer mysql because alpine uses mariadb client](https://github.com/selim13/docker-automysqlbackup/issues/6)
	In switching to a different base for the container, there were things that
	needed to change for compatibility reasons. Mainly using apt-get instead
	of the package installer used in alpine.
2. Needed 'last' file to have same name prefix as scheduled files.
3. Needed to be able to run container with restore command rather than docker
   exec to run it. (Run container with `restore <filename>` as arguments.)
4. Restore needed to be able to get the most recent backup as a default if
   filename was omitted.
5. Setting up the crontab in the container needed some work. Since this
   container is disposable, there is no need to preserve existing
   crontabs in the entrypoint. There will only be one, and we overwrite
   it.
6. BACKUP_WINDOW variable could have quotes in it for ci/cd reasons, so we
   have to remove the quotes or it breaks crontab.


# Docker-full-mysql-backup-s3

Container to backup and restore your entire MySQL database, including all databases in your host, users, permissions... using awscli.

This is not a valid solution for big databases. It will work fine for small applications. It is thought to be used for a volatile mysql database (e.g. a mysql database run a docker inside a multicontainer that could reload from time to time, [more info](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html).

# Container startup explained

* This container user cron to make backups
* Mysql will dump the database to this container and compress it using gzip
* Using s3cli the file will be uploaded to S3 Storage.
* To run a manual backup just enter the container and run:

  ```bash
  ./backup
  ```
This will create a file in you bucket that will look like `default-2015-08-03_17-58.sql.gz`. It will also create a copy of this file called `last.sql.gz`. So we can reference always the very last backup in a very easy way.

* To restore a db just enter the container and run the 'restore' script with the file name to restore:

  ```bash
  ./restore example.sql.gz
  ```
This action should be only done on a freshly created database with root user. This will re-create all the users that were previously there, recreate all the databases and all the data. 


# Environment variables

- _`$MYSQL_PASSWORD`_ - The password to connect with Mysql.
- _`$MYSQL_USER`_ - The username to connect with Mysql.
- _`$AWS_ACCESS_KEY_ID`_ - Aws acess key.
- _`$AWS_SECRET_ACCESS_KEY`_ -Aws secret key.
- _`$BUCKET`_ - Aws bucket name .
- _`$REGION`_ - Aws region where your bucket is.
- _`$MYSQL_PORT`_ - Port to connect with Mysql.
- _`$MYSQL_HOST`_ - Host where mysql is running.
- _`$FILENAME`_ - Name to file in S3 Storage. Default name `default-date +"%Y-%m-%d_%H-%M"` output example `default-2015-08-03_17-58`
- _`$BACKUP_WINDOW`_ - What time should backup run. you should use crontab format, so see [documentation](http://www.freebsd.org/cgi/man.cgi?crontab(5). default value every day at 6 am.
- _`$KILL_IF_ANY_FAIL`_ - If any error occurs while the backing up proccess, we will kill the docker container will be finished
- _`$RESTORE_ON_START`_ - Restores last.sql.gz, at the moment of start the docker container


# Example of running

```bash
docker run --rm --name mysql-backup \
  --env AWS_ACCESS_KEY_ID=--your-aws-access-key-- \
  --env AWS_SECRET_ACCESS_KEY=--your-aws-secret-key-- \
  --env BUCKET=backups.example.com \
  --env REGION=eu-west-1  \
  --env FILENAME=backup \
  --env MYSQL_HOST=test.mysql.net \
  --env MYSQL_USER=root \
  --env MYSQL_PASSWORD=password \
  --env BACKUP_WINDOW='0 6 * * *' \
  alvarohurtado84/docker-full-mysql-backup-s3

```
This will upload to Aws S3 a file named `backup-2015-08-04_09-47.sql.gz` everyday at 6am.

### Building image

```bash
docker build -t alvarohurtado84/docker-full-mysql-backup-s3 .
```
