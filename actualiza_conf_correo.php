<? 

$titulo="Actualización de ficheros de configuracion en el servidor de correo";
include ('lib/conf.inc');

top_barra_menu();


  echo "<PRE>";

  system("/mnt/intweb/intradesa/userswin/actualiza_conf_correo.sh");

  echo "</PRE>";


pie_barra_menu();

?>

