<?
require("lib/conf.inc");
$titulo = "Gestión de Usuarios de windows";

top_barra_menu();

if ($nivel < 1) { echo '<h2><font color=#ff0000>Usted no tiene autorizaci&oacute;n para utilizar esta aplicaci&oacute;n </font></h2>'; exit;}



echo "<form action=\"generar_ldf.php\" method=post>";

echo "<h1>Alta de Usuarios</h1>";


$user=getParametro('user');
$nboe=getParametro('nboe');
$pass=getParametro('pass');
$correo=getParametro('correo');




if (!$user)

    { echo "<font color=RED>Debe insertar un nombre de usuario</font>";
       exit; }

  $select_existe="select numboe from boe_listin_users_win where numboe='$nboe' ";
  $query=db_query($conn,$select_existe);
          $resultado = db_fetch_array($query);
        //   $existe=$resultado["NUMBOE"];


  if (isset($resultado["NUMBOE"]))

  { echo "<font color=RED>Ya existe un usuario para este Numboe</font>";
       exit; }

   $insertar_usuario="Insert into boe_listin_users_win (NUMBOE,USUARIO,PASSWORD,CORREO) values ('$nboe',upper('$user'),'$pass',lower('$correo'))";
   $insrt=db_query($conn,$insertar_usuario);

   $upd_personas="update rrhh.personas set usuario = lower('$user'), email = '$correo' where numboe = '$nboe'";
   $updat=db_query($conn,$upd_personas);
   
   // ini mbg1: insertamos lineas de permisos en grupos de cliente en OTRS
   try {
       $db = \dba\Database::factory ( \dba\Database::MARIADB, $CFG->aplicacion, $CFG->sid_mdb );
       
       $hoy = date ( 'Ymd' );
       // insertamos los accesos solo si no existian previamente
       
       // igualamos variables para equiparar codigo con insermodif
       $us = $user;
       
       $selectOTRS = "select * from OTRS.GROUP_CUSTOMER_USER where user_id = lower('$us')";
       
       $resultSelectOTRS = $db->fetchAll ( $selectOTRS );
       if (! isset ( $resultSelectOTRS [0] )) {
           $permisos_otrs = "INSERT INTO OTRS.GROUP_CUSTOMER_USER (USER_ID, GROUP_ID, PERMISSION_KEY, PERMISSION_VALUE, CREATE_TIME, CREATE_BY, CHANGE_TIME, CHANGE_BY) VALUES (lower('$us'),1,'rw',1,'$hoy',28,'$hoy',28);
			INSERT INTO OTRS.GROUP_CUSTOMER_USER (USER_ID, GROUP_ID, PERMISSION_KEY, PERMISSION_VALUE, CREATE_TIME, CREATE_BY, CHANGE_TIME, CHANGE_BY) VALUES (lower('$us'),24,'rw',1,'$hoy',28,'$hoy',28);
			INSERT INTO OTRS.GROUP_CUSTOMER_USER (USER_ID, GROUP_ID, PERMISSION_KEY, PERMISSION_VALUE, CREATE_TIME, CREATE_BY, CHANGE_TIME, CHANGE_BY) VALUES (lower('$us'),181,'rw',1,'$hoy',28,'$hoy',28);
			INSERT INTO OTRS.GROUP_CUSTOMER_USER (USER_ID, GROUP_ID, PERMISSION_KEY, PERMISSION_VALUE, CREATE_TIME, CREATE_BY, CHANGE_TIME, CHANGE_BY) VALUES (lower('$us'),27,'rw',1,'$hoy',28,'$hoy',28);
			INSERT INTO OTRS.GROUP_CUSTOMER_USER (USER_ID, GROUP_ID, PERMISSION_KEY, PERMISSION_VALUE, CREATE_TIME, CREATE_BY, CHANGE_TIME, CHANGE_BY) VALUES (lower('$us'),26,'rw',1,'$hoy',28,'$hoy',28);
            INSERT INTO OTRS.GROUP_CUSTOMER_USER (USER_ID, GROUP_ID, PERMISSION_KEY, PERMISSION_VALUE, CREATE_TIME, CREATE_BY, CHANGE_TIME, CHANGE_BY) VALUES (lower('$us'),673,'rw',1,'$hoy',28,'$hoy',28);
			INSERT INTO OTRS.GROUP_CUSTOMER_USER (USER_ID, GROUP_ID, PERMISSION_KEY, PERMISSION_VALUE, CREATE_TIME, CREATE_BY, CHANGE_TIME, CHANGE_BY) VALUES (lower('$us'),141,'rw',1,'$hoy',28,'$hoy',28);
			INSERT INTO OTRS.GROUP_CUSTOMER_USER (USER_ID, GROUP_ID, PERMISSION_KEY, PERMISSION_VALUE, CREATE_TIME, CREATE_BY, CHANGE_TIME, CHANGE_BY) VALUES (lower('$us'),81,'rw',1,'$hoy',28,'$hoy',28);";
           $db->execute ( $permisos_otrs );
       }
   } catch ( Exception $e ) {
       echo ('Error al dar de alta en la tabla OTRS.GROUP_CUSTOMER_USER de OTRS: ');
       echo ($e->getMessage ());
   }
   // fin mbg1
   
     echo "Inserción realizada correctamente.";

	 echo "<br><br><input type=\"submit\"  value=\" Generar LDIF \">"; 
	 echo "<input type=\"hidden\" name=\"numboe\" value=\"$nboe\">";
	 echo "<input type=\"hidden\" name=\"correo\" value=\"$correo\">";

?>
</form>


<?
pie_barra_menu();

?>
