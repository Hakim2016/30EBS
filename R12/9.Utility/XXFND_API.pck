CREATE OR REPLACE PACKAGE XXFND_API AS
/*==================================================
  Copyright (C) HAND Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
/*==================================================
  Program Name:
      XXFND_API
  Description:
      This program provide common API for procedure
  History:
      1.00  2006-06-01  jim.lin    Creation
  ==================================================*/

   -- Global Constants
   G_FND_APP            CONSTANT VARCHAR2(200) := 'FND';
   G_APP_NAME           CONSTANT VARCHAR2(200) := 'CUX';

   -- execute exception type
   G_EXC_NAME_ERROR     CONSTANT VARCHAR2(30) := 'ERROR';
   G_EXC_NAME_UNEXP     CONSTANT VARCHAR2(30) := 'UNEXP';
   G_EXC_NAME_OTHERS    CONSTANT VARCHAR2(30) := 'OTHERS';

   -- table action type
   G_ACT_CREATE         CONSTANT VARCHAR2(30) := 'CREATE';
   G_ACT_UPDATE         CONSTANT VARCHAR2(30) := 'UPDATE';
   G_ACT_DELETE         CONSTANT VARCHAR2(30) := 'DELETE';

   -- table event type
   TYPE EVENT_ENABLE_TYPE IS ARRAY(6) OF BOOLEAN;
   INIT_EVENT_ENABLE EVENT_ENABLE_TYPE := EVENT_ENABLE_TYPE(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE);

   G_EVT_PRE_INSERT     CONSTANT PLS_INTEGER := 1; -- 'PRE_INSERT';
   G_EVT_POST_INSERT    CONSTANT PLS_INTEGER := 2; -- 'POST_INSERT';
   G_EVT_PRE_UPDATE     CONSTANT PLS_INTEGER := 3; -- 'PRE_UPDATE';
   G_EVT_POST_UPDATE    CONSTANT PLS_INTEGER := 4; -- 'POST_UPDATE';
   G_EVT_PRE_DELETE     CONSTANT PLS_INTEGER := 5; -- 'PRE_DELETE';
   G_EVT_POST_DELETE    CONSTANT PLS_INTEGER := 6; -- 'POST_DELETE';

/*=============================================
  Procedure Name:

  Description:

  Argument:

  Return:

  History:
      1.00  2006-06-01  jim.lin    Creation
  =============================================*/
  PROCEDURE init_msg_list (
              p_init_msg_list         IN VARCHAR2
            );

  FUNCTION start_activity (
              p_pkg_name              IN VARCHAR2,
              p_api_name              IN VARCHAR2,
              p_savepoint_name        IN VARCHAR2 DEFAULT NULL,
              p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
              l_api_version           IN NUMBER DEFAULT NULL,
              p_api_version           IN NUMBER DEFAULT NULL
            ) RETURN VARCHAR2;

  PROCEDURE end_activity (
              p_pkg_name              IN VARCHAR2,
              p_api_name              IN VARCHAR2,
              p_commit                IN  VARCHAR2 DEFAULT NULL,
              x_msg_count             OUT NOCOPY NUMBER,
              x_msg_data              OUT NOCOPY VARCHAR2
            );

  FUNCTION handle_exceptions (
              p_pkg_name              IN VARCHAR2,
              p_api_name              IN VARCHAR2,
              p_savepoint_name        IN VARCHAR2 DEFAULT NULL,
              p_exc_name              IN VARCHAR2,
              x_msg_count             OUT NOCOPY NUMBER,
              x_msg_data              OUT NOCOPY VARCHAR2
            ) RETURN VARCHAR2;

  PROCEDURE set_message (
              p_app_name              IN VARCHAR2 DEFAULT XXFND_API.G_APP_NAME,
              p_msg_name              IN VARCHAR2,
              p_token1                IN VARCHAR2 DEFAULT NULL,
              p_token1_value          IN VARCHAR2 DEFAULT NULL,
              p_token2                IN VARCHAR2 DEFAULT NULL,
              p_token2_value          IN VARCHAR2 DEFAULT NULL,
              p_token3                IN VARCHAR2 DEFAULT NULL,
              p_token3_value          IN VARCHAR2 DEFAULT NULL,
              p_token4                IN VARCHAR2 DEFAULT NULL,
              p_token4_value          IN VARCHAR2 DEFAULT NULL,
              p_token5                IN VARCHAR2 DEFAULT NULL,
              p_token5_value          IN VARCHAR2 DEFAULT NULL
            );

  PROCEDURE raise_exception(
              p_app_name              IN VARCHAR2 DEFAULT XXFND_API.G_APP_NAME,
              p_msg_name              IN VARCHAR2 DEFAULT NULL,
              p_token1                IN VARCHAR2 DEFAULT NULL,
              p_token1_value          IN VARCHAR2 DEFAULT NULL,
              p_token2                IN VARCHAR2 DEFAULT NULL,
              p_token2_value          IN VARCHAR2 DEFAULT NULL,
              p_token3                IN VARCHAR2 DEFAULT NULL,
              p_token3_value          IN VARCHAR2 DEFAULT NULL,
              p_token4                IN VARCHAR2 DEFAULT NULL,
              p_token4_value          IN VARCHAR2 DEFAULT NULL,
              p_token5                IN VARCHAR2 DEFAULT NULL,
              p_token5_value          IN VARCHAR2 DEFAULT NULL);

END XXFND_API;
/
CREATE OR REPLACE PACKAGE BODY XXFND_API AS
/*==================================================
  Copyright (C) HAND Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
/*==================================================
  Program Name:
      XXFND_API
  Description:
      This program provide common API for procedure
  History:
      1.00  2006-06-01  jim.lin    Creation
  ==================================================*/

  -- Global variable
  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE init_msg_list (
              p_init_msg_list         IN VARCHAR2
            )
  IS
  BEGIN
    IF (FND_API.to_boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
    END IF;
  END init_msg_list;

  FUNCTION start_activity (
              p_pkg_name              IN VARCHAR2,
              p_api_name              IN VARCHAR2,
              p_savepoint_name        IN VARCHAR2 DEFAULT NULL,
              p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
              l_api_version           IN NUMBER DEFAULT NULL,
              p_api_version           IN NUMBER DEFAULT NULL
           ) RETURN VARCHAR2
  IS
  BEGIN
    -- set debug indentation
    IF (l_debug = 'Y') THEN
       XXFND_debug.set_indentation(p_pkg_name || '.' || p_api_name);
       XXFND_debug.log('Entering ',2);
    END IF;

    -- compare api version
    IF l_api_version IS NOT NULL AND p_api_version IS NOT NULL THEN
      IF NOT fnd_api.compatible_api_call(
                 l_api_version,
                      p_api_version,
                      p_api_name,
                      p_pkg_name)
      THEN
        RETURN(fnd_api.g_ret_sts_unexp_error);
      END IF;
    END IF;

    -- Standard start of API savepoint
    IF p_savepoint_name IS NOT NULL THEN
      dbms_transaction.savepoint(p_savepoint_name);
    END IF;

    -- initialize message list
    init_msg_list(p_init_msg_list);

    RETURN(fnd_api.g_ret_sts_success);

  END start_activity;

  PROCEDURE end_activity (
                p_pkg_name              IN VARCHAR2,
                p_api_name              IN VARCHAR2,
                p_commit                IN  VARCHAR2 DEFAULT NULL,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2
            )
  IS
  BEGIN
     -- standard check for automatic commit
     IF p_commit IS NOT NULL THEN
       IF fnd_api.to_boolean(p_commit) THEN
          COMMIT WORK;
       END IF;
     END IF;

     --- Standard call to get message count and if count is 1, get message info
     fnd_msg_pub.count_and_get
           ( p_encoded => fnd_api.g_false,
             p_count   => x_msg_count,
             p_data    => x_msg_data );

     -- reset debug indentation
     IF (l_debug = 'Y') THEN
        XXFND_debug.log('Leaving',2);
        XXFND_debug.Reset_Indentation(p_pkg_name || '.' || p_api_name);
     END IF;
  END end_activity;

  FUNCTION handle_exceptions (
                p_pkg_name              IN VARCHAR2,
                p_api_name              IN VARCHAR2,
                p_savepoint_name        IN VARCHAR2 DEFAULT NULL,
                p_exc_name              IN VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2
           ) RETURN VARCHAR2
  IS
     l_return_value          VARCHAR2(30) := fnd_api.g_ret_sts_unexp_error;
     l_log_level             NUMBER := 6;
  BEGIN
    -- standard check for rollback to savepoint
    IF p_savepoint_name IS NOT NULL THEN
      dbms_transaction.rollback_savepoint(p_savepoint_name);
    END IF;

    IF p_exc_name = XXFND_api.g_exc_name_error THEN
      fnd_msg_pub.count_and_get
            ( p_encoded => fnd_api.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data );
      l_return_value := fnd_api.g_ret_sts_error;
      l_log_level := 4;
    ELSIF p_exc_name = XXFND_api.g_exc_name_unexp THEN
      fnd_msg_pub.count_and_get
            ( p_encoded => fnd_api.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data );
      l_log_level := 5;
    ELSE -- when others exception
      -- substrb(SQLERRM, 240) fnd_msg_pub may occur error when sqlerrm containt multi-byte string
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg( p_pkg_name, p_api_name, substrb(SQLERRM, 1, 240));
      END IF;
      fnd_msg_pub.count_and_get
            ( p_encoded => fnd_api.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data );
      l_log_level := 6;
    END IF;

    -- reset debug indentation
    IF (l_debug = 'Y') THEN
      XXFND_debug.log('Leaving error : ' || x_msg_data, l_log_level);
      XXFND_debug.Reset_Indentation(p_pkg_name || '.' || p_api_name);
    END IF;

    RETURN(l_return_value);
  END handle_exceptions;

  PROCEDURE set_message (
              p_app_name              IN VARCHAR2 DEFAULT XXFND_api.g_app_name,
              p_msg_name              IN VARCHAR2,
              p_token1                IN VARCHAR2 DEFAULT NULL,
              p_token1_value          IN VARCHAR2 DEFAULT NULL,
              p_token2                IN VARCHAR2 DEFAULT NULL,
              p_token2_value          IN VARCHAR2 DEFAULT NULL,
              p_token3                IN VARCHAR2 DEFAULT NULL,
              p_token3_value          IN VARCHAR2 DEFAULT NULL,
              p_token4                IN VARCHAR2 DEFAULT NULL,
              p_token4_value          IN VARCHAR2 DEFAULT NULL,
              p_token5                IN VARCHAR2 DEFAULT NULL,
              p_token5_value          IN VARCHAR2 DEFAULT NULL
           )
  IS
  BEGIN
       fnd_message.set_name( p_app_name, p_msg_name);
       IF (p_token1 IS NOT NULL) THEN
               fnd_message.set_token(  token   => p_token1,
                                       value   => p_token1_value);
       END IF;
       IF (p_token2 IS NOT NULL) THEN
               fnd_message.set_token(  token   => p_token2,
                                       value   => p_token2_value);
       END IF;
       IF (p_token3 IS NOT NULL) THEN
               fnd_message.set_token(  token   => p_token3,
                                       value   => p_token3_value);
       END IF;
       IF (p_token4 IS NOT NULL) THEN
               fnd_message.set_token(  token   => p_token4,
                                       value   => p_token4_value);
       END IF;
       IF (p_token5 IS NOT NULL) THEN
               fnd_message.set_token(  token   => p_token5,
                                       value   => p_token5_value);
       END IF;
       fnd_msg_pub.add;
  END set_message;

  PROCEDURE raise_exception(
              p_app_name              IN VARCHAR2 DEFAULT XXFND_api.g_app_name,
              p_msg_name              IN VARCHAR2 DEFAULT NULL,
              p_token1                IN VARCHAR2 DEFAULT NULL,
              p_token1_value          IN VARCHAR2 DEFAULT NULL,
              p_token2                IN VARCHAR2 DEFAULT NULL,
              p_token2_value          IN VARCHAR2 DEFAULT NULL,
              p_token3                IN VARCHAR2 DEFAULT NULL,
              p_token3_value          IN VARCHAR2 DEFAULT NULL,
              p_token4                IN VARCHAR2 DEFAULT NULL,
              p_token4_value          IN VARCHAR2 DEFAULT NULL,
              p_token5                IN VARCHAR2 DEFAULT NULL,
              p_token5_value          IN VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
     IF p_app_name IS NOT NULL AND p_msg_name IS NOT NULL THEN
       fnd_message.set_name( p_app_name, p_msg_name);
       IF (p_token1 IS NOT NULL) THEN
               fnd_message.set_token(  token    => p_token1,
                                       value    => p_token1_value);
       END IF;
       IF (p_token2 IS NOT NULL) THEN
               fnd_message.set_token(  token    => p_token2,
                                       value    => p_token2_value);
       END IF;
       IF (p_token3 IS NOT NULL) THEN
               fnd_message.set_token(  token    => p_token3,
                                       value    => p_token3_value);
       END IF;
       IF (p_token4 IS NOT NULL) THEN
               fnd_message.set_token(  token    => p_token4,
                                       value    => p_token4_value);
       END IF;
       IF (p_token5 IS NOT NULL) THEN
               fnd_message.set_token(  token    => p_token5,
                                       value    => p_token5_value);
       END IF;
       app_exception.raise_exception;
     ELSE
       app_exception.raise_exception( exception_type => p_app_name,
                                      exception_code => SQLCODE,
                                      exception_text => SQLERRM);
     END IF;
  END raise_exception;

END XXFND_API;
/
