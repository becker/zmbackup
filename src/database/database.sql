  create table backup_session (
    id varchar primary key,
    initial_date timestamp not null,
    conclusion_date timestamp,
    size varchar,
    type varchar not null,
    status varchar not null
  );

  create table backup_account (
    id integer primary key autoincrement,
    session_id varchar not null,
    account_size varchar not null,
    email varchar not null,
    initial_date timestamp not null,
    conclusion_date timestamp,
    foreign key (session_id) references backup_session(id)
  );
