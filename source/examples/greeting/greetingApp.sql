CREATE OR REPLACE PROCEDURE greeting (name_array    IN owa_util.vc_arr DEFAULT dbx.empty_vc_arr
                                    , value_array   IN owa_util.vc_arr DEFAULT dbx.empty_vc_arr )
AS
   /* Unique application ID Name */
   l_appid CONSTANT   VARCHAR2 (100) := 'GREETING';
BEGIN
   /**
   * Aplication properties
   */
   dbx.g$properties ('base_path') := '/ords/!greeting?p=';
   dbx.g$properties ('resources_url') := 'http://v4-alpha.getbootstrap.com';
   dbx.g$properties ('encoding') := 'UTF-8';
   dbx.g$properties ('error_style') := 'DebugStyle';

   /* Properties frequently used in views */
   view_.data ('resources_url', dbx.g$properties ('resources_url'));
   view_.data ('base_path', dbx.g$properties ('base_path'));

   /**
   * @param     appid           The unique application ID
   * @param     name_array      User name parameters
   * @param     value_array     User value parameters
   * @param     Router          Your application routing function
   */
   dbx.dispatcher (p_appid     => l_appid
                 , name_array  => name_array
                 , value_array => value_array
                 , router      => 'PK_APP_GREETING.ROUTER');
END greeting;
/

CREATE OR REPLACE PACKAGE pk_app_greeting
AS
   /**
   * Application router
   */
   FUNCTION router
      RETURN CLOB;

   /**
   * Greeting Controller
   */   
   FUNCTION greeting_controller
      RETURN CLOB;

   /**
   * Reretrive user input data and save it in session. 
   */
   FUNCTION user_inputs_controller
      RETURN CLOB;

   /**
   * Greeting View
   */
   FUNCTION greeting_view
      RETURN CLOB;
END;
/

CREATE OR REPLACE PACKAGE BODY pk_app_greeting
AS
   /**
   * Application router
   */
   FUNCTION router
      RETURN CLOB
   AS
   BEGIN
      IF route_.get ('/')
      THEN
         RETURN greeting_controller ();
      END IF;

      IF route_.post ('/')
      THEN
         RETURN user_inputs_controller ();
      END IF;
   END;

   /**
   * Greeting Controller
   */
   FUNCTION greeting_controller
      RETURN CLOB
   AS
      l_input_name   VARCHAR2 (3000);
      l_input_age    PLS_INTEGER;
   BEGIN
      l_input_name := session_.get ('l_input_name');
      l_input_age := session_.get ('l_input_age');
      session_.flush ();

      view_.data ('l_input_name', l_input_name);
      view_.data ('l_input_age', l_input_age);

      RETURN view_.run (greeting_view (), 'greeting');
   END greeting_controller;

   /**
   * Reretrive user input data and save it in session. 
   */
   FUNCTION user_inputs_controller
      RETURN CLOB
   AS
      l_input_name   VARCHAR2 (300);
      l_input_age    PLS_INTEGER;
   BEGIN
      l_input_name := request_.input ('inputName');
      l_input_age := request_.input ('inputAge');

      session_.set ('l_input_name', l_input_name);
      session_.set ('l_input_age', l_input_age);

      dbx.redirect ('/');
      RETURN NULL;
   END user_inputs_controller;

   /**
   * Greeting View
   */
   FUNCTION greeting_view
      RETURN CLOB
   AS
   BEGIN
      RETURN q'[<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Simple Greerting application">
    <meta name="author" content="Oscar Salvador Magallanes">
    

    <title>Greeting from dbax</title>

    <!-- Bootstrap core CSS -->
    <link href="${resources_url}/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="${resources_url}/examples/signin/signin.css" rel="stylesheet">
  </head>

  <body>

    <div class="container">

      <% if l_input_name is not null then%>
          <h2>Hi <%= l_input_name %>! you are <%= l_input_age %> years old</h2>
      <% else %>
          <form class="form-signin" method="POST" action="${base_path}/">
            <h2 class="form-signin-heading">Greeting App!</h2>
            <label for="inputName" class="sr-only">Your name</label>
            <input type="text" name="inputName" id="inputName" class="form-control" placeholder="Your name" required autofocus>
            <label for="inputAge" class="sr-only">Your age</label>
            <input type="number" name="inputAge" id="inputAge" class="form-control" placeholder="Your age" required>
            <button class="btn btn-lg btn-primary btn-block" type="submit">Greet me!</button>
          </form>
      <% end if; %>

    </div> <!-- /container -->


    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="${resources_url}/assets/js/ie10-viewport-bug-workaround.js"></script>
  </body>
</html>

      ]';
   END greeting_view;
END;