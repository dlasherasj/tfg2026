<?

require("lib/conf.inc");
$titulo = "Gestión de Usuarios de Windows";

top_barra_menu();

if ($nivel < 1) { echo '<h2><font color=#ff0000>Usted no tiene autorizaci&oacute;n para utilizar esta aplicaci&oacute;n </font></h2>'; exit;}

$usuario=getParametro('usuario');

if ($usuario != '') {

echo "<h1>Creacion del PCV personal en VMWARE ESXi</h1>"; 

echo "<BR>";

$pass=xxxxx;
$pcv="PCV-".strtoupper($usuario);

// Primero intentamos detectar si hay algun error en el ID del usuario (por lo menos que exista)

// Obtenemos el numboe del usuario                                                                                                                                      
                                                                                                                                                                        
$sql="select apellid1, apellid2, nombre from personas_min where usuario='$usuario'";                                                                                                        
$query=db_query($conn,$sql);                                                                                                                                            
$resultado = db_fetch_array($query);                                                                                                                                    
$nombre_completo=$resultado["NOMBRE"]." ".$resultado["APELLID1"]." ".$resultado["APELLID2"];
                                                                                                                                                                        
echo "El usuario <b>$usuario</b> existe y su nombre completo es <b>$nombre_completo</b> <BR><BR><BR>";  
echo "Procedemos...<BR><BR><BR>";

echo "<B>Creando el objeto del PCV personal del usuario en AD...</B><BR>";

$comando="DSADD COMPUTER cn=$pcv,ou=VDI_W11,ou=PCsW10,ou=Equipos,dc=boe,dc=int ";
$salida=shell_exec("export SSHPASS=$pass ; sshpass -e ssh $CFG->xxxx@xxxx \"$comando\" 2>&1 ");

echo "Resultado de la creacion del objeto PCV en AD:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";

echo "<BR><BR>\n";

echo "<B>AVISO: El siguiente proceso puede tardar hasta 5 minutos. Ten paciencia y no abortes la carga de la página.</B><BR>";

// Creacion del PCV via PowerShell
// pwsh -Command ./vm_crea_pcv.ps1 $i
// printf "$i\|" >> mac_pcvs.txt
// pwsh -Command ./vm_get_mac.ps1 $i | tail -2 |head -1 >> mac_pcvs.txt

echo "<BR>\n";

echo "<B>Creando el PCV via PowerShell...</B><BR>";

ob_flush();
flush();

$ruta_scripts = "/scripts/";
$pcv="PCV-".strtoupper($usuario);
$current_user = trim(shell_exec('whoami'));

$comando="export HOME=/home/$current_user ; pwsh -Command $ruta_scripts/vm_crea_pcv.ps1 $pcv ";
$salida=shell_exec("$comando 2>&1 ");

echo "<BR>\n";

echo "Resultado de la creacion del PCV en ESXi:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";



echo "<B>Extraemos la MAC del PCV recien creado via PowerShell...</B><BR>";

$ruta_scripts = "/scripts/";
$pcv="PCV-".strtoupper($usuario);
$current_user = trim(shell_exec('whoami'));

$comando="export HOME=/home/$current_user; pwsh -Command $ruta_scripts/vm_get_mac.ps1 $pcv | tail -2 | head -1 ";
$salida=shell_exec("$comando 2>&1 ");
$mac=trim($salida);

echo "Resultado de la creacion del PCV en ESXi:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";



echo "<B>Insertamos los datos del PCV recien creado en GEISER, con la MAC ya actualizada para el DHCP...</B><BR>";
echo "<B> ... asignando la primera IP libre del rango de PCVs...</B><BR>";


// Obtenemos el numboe del usuario

$sql="select numboe from personas_min where usuario='$usuario'";
$query=db_query($conn,$sql);
$resultado = db_fetch_array($query);
$numboe=$resultado["NUMBOE"];

echo "El numboe es $numboe <BR>";


//Insercion en GEISER_EQUIPOS

// Pero antes, limpiamos ocurrencias previas del equipo en GEISER
// 1 - GEISER_INTERFAZ
// 2 - GEISER_EQUIPOS_PERS
// 3 - GEISER_EQUIPOS

echo "Eliminamos cualquier ocurrencia anterior del equipo $pcv en GEISER_INTERFAZ<BR>";                                                                                    
                                                                                                                                                                        
$sql = "delete from geiser_interfaz where ID_EQUIPO = '$pcv'";                   
echo "<PRE>";
echo "$sql";                                                                                                                                                            
echo "</PRE>";
$query=db_query($conn,$sql);

echo "Eliminamos cualquier ocurrencia anterior del equipo $pcv en GEISER_EQUIPOS_PERS<BR>";                                                                                    
                                                                                                                                                                        
$sql = "delete from geiser_equip_pers where ID_EQUIPO = '$pcv'";                   
echo "<PRE>";
echo "$sql"."<br>";                                                                                                                                                            
echo "</PRE>";
$query=db_query($conn,$sql);

echo "Eliminamos cualquier ocurrencia anterior del equipo $pcv en GEISER_EQUIPOS<BR>";

$sql = "delete from geiser_equipos where ID_EQUIPO = '$pcv'";
echo "<PRE>";
echo "$sql";
echo "</PRE>";
echo "$sql"."<br>";
$query=db_query($conn,$sql);

// Ahora si, procedemos con los INSERT

echo "Tratamos de insertar $pcv en GEISER_EQUIPOS<BR>";

$sql = "insert into geiser_equipos (ID_EQUIPO,TIPO_EQUIPO,ID_MARCA,ID_MODELO,ID_SO_TIPO,ID_USO) values ('$pcv','VDI',22,2,16,1)";
echo "<PRE>";
echo "$sql";
echo "</PRE>";

$query=db_query($conn,$sql);

// Insercion en GEISER_EQUIP_PERS

echo "Tratamos de insertar $pcv en GEISER_EQUIP_PERS relacionado con $usuario/$numboe<BR>";

$sql = "insert into geiser_equip_pers (ID_EQUIPO,NUMBOESERV,EQUIP_PRINCIP,PERS_PRINCIP) values ('$pcv',$numboe,'S','S')";
echo "<PRE>";
echo "$sql";
echo "</PRE>";
$query=db_query($conn,$sql);


// Insercion en GEISER_INTERFAZ

// Obtenemos la siguiente IP libre, entendemos que de la red 10.14.147.

$sql="select max(id_ip) IP from geiser_interfaz where prefijo_ip_red='10.14.147.' and ID_IP<'210'";
$query=db_query($conn,$sql);
$resultado = db_fetch_array($query);
$ip=$resultado["IP"];

$ip++;

echo "Insertamos la IP $ip<BR>";

// formateo de datos a insertar

$mac=strtoupper($mac);
$pcv=strtoupper("PCV-".$usuario);
$pcv_dns=strtolower("PCV-".$usuario.".boe.int");

echo "Tratamos de insertar la MAC $mac en GEISER_INTERFAZ relacionada con $pcv<BR>";

$sql = "insert into geiser_interfaz (PREFIJO_IP_RED,ID_IP,DNSNAME,INTERFAZ,ID_EQUIPO,MAC) values ('10.14.147.',$ip,'$pcv_dns','eth0','$pcv','$mac')";
echo "<PRE>";
echo "$sql";
echo "</PRE>";
$query=db_query($conn,$sql);


echo "<BR><BR>\n";

// Boton para la actualizacion del DHCP en una ventana aparte...

echo "<B>IMPORTANTE:</B> Si todo lo anterior es correcto, puede proceder con la <B>actualización de los ficheros DHCP<B>,<BR>
ejecutando el siguiente enlace en una nueva ventana.<BR>";


    echo "<form action=\"../geiser/refresca_dhcp.php\" method=post target=\"_blank\">";
    echo "<br><br><input type=\"submit\"  value=\" Refresco del DHCP \">";
    echo "</form>";

echo "<BR><BR>\n";

echo "<B>Si la actualización de DHCP ha ido bien, puede proceder con el <B>arranque del PCV recien creado<B>,<BR>
ejecutando el siguiente enlace en una nueva ventana.<BR>";

    echo "<form action=\"arranca_pcv.php\" method=post target=\"_blank\">";
    echo "<input type=\"hidden\" name=\"usuario\" value=\"$usuario\">";
    echo "<br><br><input type=\"submit\"  value=\" Arranque del PCV nuevo \">";
    echo "</form>";

echo "<BR><BR>\n";

} else {

echo "<BR><BR>\n";

echo "<B>IMPORTANTE:</B> Para ejecutar este procedimiento, asegurarse previamente de que el PCV que se pretende crear no exista en ESXi.";

echo "<BR><BR>\n";

   echo "<form action=\"crea_pcv_usuario.php\" method=post>";
    echo "Identificador corto del usuario (3 letras y 1 numero) ";
    echo "<input type=\"text\" name=\"usuario\" size =\"4\" value=\"\">";
    echo "<br><br><input type=\"submit\"  value=\" Crear el PCV del usuario en VMWARE \">";
    echo "</form>";

}

pie_barra_menu();


?>


