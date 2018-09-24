create database testbase;
create user testuser password 'secret';
\c testbase
create table testtable (testint integer, testtext text);
insert into testtable (testint, testtext) values (17, 'foobar');
grant select on testtable to testuser;
