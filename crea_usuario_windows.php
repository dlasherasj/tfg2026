<?

require("lib/conf.inc");
require_once("$CFG->dirintranet/userswin/lib/userswin.inc");

$titulo = "Gestión de Usuarios de Windows";

top_barra_menu();

if ($nivel < 1) { echo '<h2><font color=#ff0000>Usted no tiene autorizaci&oacute;n para utilizar esta aplicaci&oacute;n </font></h2>'; exit;}

$usuario=getParametro('usuario');
//$usuario='mgp2';

echo "<h1>Creacion del usuario en WINDOWS</h1>"; 

echo "<BR>";

$pass=descifra_simple($CFG->ADadminpwd);

echo "<B>Cargando en AD el LDIF del usuario...</B><BR>";

$comando="LDIFDE -i -f \\\\\\server\\repositorio\\usuarios\\$usuario.ldf";
$salida=shell_exec("export SSHPASS=$pass ; sshpass -e ssh $CFG->ADadmin@deploy \"$comando\" 2>&1 ");

echo "Resultado de la carga del LDIF en AD:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";

echo "<B>Generando password para el usuario...</B><BR>";

$clave_usuario=genera_pass();

$comando="DSQUERY USER -samid $usuario | DSMOD USER -pwd $clave_usuario ";
$salida=shell_exec("export SSHPASS=$pass ; sshpass -e ssh $CFG->ADadmin@deploy \"$comando\" 2>&1 ");

echo "Resultado de la configuracion de la password del usuario:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";
echo "<BR><B>NOTA:</B>La password generada para el usuario es: <B>$clave_usuario</B><BR>";


echo "<B>Forzando el cambio de password en el primer login...</B><BR>";

$comando="NET USER $usuario /logonpasswordchg:yes /domain ";
$salida=shell_exec("export SSHPASS=$pass ; sshpass -e ssh $CFG->ADadmin@deploy \"$comando\" 2>&1 ");

echo "Resultado del forzado de cambio de password en el primer login:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";


echo "<BR>";
  
echo "<B>Configurando la inclusion del usuario en el grupo de politica de passwords...</B><BR>";

$comando="NET GROUP \"Password_Policy_Users\" $usuario /add /domain";
$salida=shell_exec("export SSHPASS=$pass ; sshpass -e ssh $CFG->ADadmin@deploy \"$comando\" 2>&1 ");

echo "Resultado de esta configuracion:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";

echo "<BR>";

echo "<B>Configurando la inclusion del usuario en el grupo de licencias de Windows y O365...</B><BR>";

$comando="NET GROUP \"Licencia_Windows_y_Office_365_BASICO\" $usuario /add /domain";
$salida=shell_exec("export SSHPASS=$pass ; sshpass -e ssh $CFG->ADadmin@deploy \"$comando\" 2>&1 ");

echo "Resultado de esta configuracion:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";

echo "<B>Creando carpeta Docs del usuario...</B><BR>";

$ruta_docs = "\\\\\\SERVER\\WINVOL\\Docs";
                                                                                                                                           
$comando="MKDIR $ruta_docs\\$usuario";                                    
$salida=shell_exec("export SSHPASS=$pass ; sshpass -e ssh $CFG->ADadmin@deploy \"$comando\" 2>&1 ");                                       
                                                                                                                                           
echo "Resultado de esta configuracion:<BR>";                                                                                               
echo "Comando:<B>$comando</B><BR>";                                                                                                        
echo "<PRE>";                                                                                                                              
echo($salida);                                                                                                                          
echo "</PRE>"; 

echo "<B>Arreglando los permisos del Docs del usuario...</B><BR>";

$ruta_docs = "\\\\\\SERVER\\WINVOL\\Docs";

$comando="ICACLS $ruta_docs\\$usuario /grant:r boe.int\\$usuario:(OI)(CI)M /T";
$salida=shell_exec("export SSHPASS=$pass ; sshpass -e ssh $CFG->ADadmin@deploy \"$comando\" 2>&1 ");

echo "Resultado del cambio de permisos:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";


echo "<B>NOTA:</B> Si todo lo anterior es correcto, el nuevo usuario se sincronizará en 30 minutos máximo desde el AD on-premises al AAD, y en ese momento dispondrá de correo electrónico, así como de licencia de Windows y O365.<BR><BR>Independientemente de ello, es necesario lanzar a mano la <b>sincronizacion del servidor de correo</b> (enlace del menú de la izquierda).<BR><BR>A continuación, puedes proceder con la <B>creacion de del PCV del usuario<B>.<BR>";

echo "<B>NOTA 2:</B> No olvides mover al usuario de la ubicación inicial (OU=Empleados) a su ubicación definitiva, con la herramienta <b>Usuarios y Equipos del Directorio Activo</b> en un servidor Windows.<BR><BR>";

    echo "<form action=\"crea_pcv_usuario.php\" method=post>";
    echo "<br><br><input type=\"submit\"  value=\" Crear el PCV del usuario en VMWARE \">";
    echo "<input type=\"hidden\" name=\"usuario\" value=\"$usuario\">";
    echo "</form>";


pie_barra_menu();

?>
