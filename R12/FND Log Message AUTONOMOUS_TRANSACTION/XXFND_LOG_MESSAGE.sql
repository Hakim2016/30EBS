CREATE TABLE XXFND.XXFND_LOG_MESSAGE
(
       LOG_ID         NUMBER,
       MODULE         VARCHAR2(255),
       MESSAGE_TEXT   VARCHAR2(4000),
       SESSION_ID     NUMBER,
       USER_ID        NUMBER,
       REQUEST_ID     NUMBER,
       PROG_APPL_ID   NUMBER,
       PROGRAM_ID     NUMBER,
       RESP_ID        NUMBER,
       RESP_APPL_ID   NUMBER,
       CREATION_DATE  DATE
);

CREATE SEQUENCE XXFND.XXFND_LOG_MESSAGE_S START WITH 1;

CREATE SYNONYM APPS.XXFND_LOG_MESSAGE FOR XXFND.XXFND_LOG_MESSAGE;
CREATE SYNONYM APPS.XXFND_LOG_MESSAGE_S FOR XXFND.XXFND_LOG_MESSAGE_S;