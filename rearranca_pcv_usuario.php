<?

require("lib/conf.inc");
$titulo = "Gestión de Usuarios de Windows";

top_barra_menu();

if ($nivel < 1) { echo '<h2><font color=#ff0000>Usted no tiene autorizaci&oacute;n para utilizar esta aplicaci&oacute;n </font></h2>'; exit;}

$usuario=getParametro('usuario');

if ($usuario != '') {

echo "<h1>Rearranque del PCV personal en VMWARE ESXi</h1>"; 

echo "<BR>";

$pass=descifra_simple($CFG->ADadminpwd);
$pcv="PCV-".strtoupper($usuario);

// Primero intentamos detectar si hay algun error en el ID del usuario (por lo menos que exista)

// Obtenemos el numboe del usuario                                                                                                                                      
                                                                                                                                                                        
$sql="select apellid1, apellid2, nombre from personas_min where usuario='$usuario'";                                                                                                        
$query=db_query($conn,$sql);                                                                                                                                            
$resultado = db_fetch_array($query);                                                                                                                                    
$nombre_completo=$resultado["NOMBRE"]." ".$resultado["APELLID1"]." ".$resultado["APELLID2"];
                                                                                                                                                                        
echo "El usuario <b>$usuario</b> existe y su nombre completo es <b>$nombre_completo</b> <BR><BR><BR>";  
echo "Procedemos...<BR><BR><BR>";

echo "<BR><BR>\n";

echo "<B>Rearrancando el PCV via PowerShell...</B><BR>";

ob_flush();
flush();

$ruta_scripts = "/scripts/";
$pcv="PCV-".strtoupper($usuario);
$current_user = trim(shell_exec('whoami'));

$comando="export HOME=/home/$current_user ; pwsh -Command $ruta_scripts/vm_restart_vm.ps1 $pcv ";
$salida=shell_exec("$comando 2>&1 ");

echo "<BR>\n";

echo "Resultado del rearranque del PCV en ESXi:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";



echo "<BR><BR>\n";

} else {

echo "<BR><BR>\n";


   echo "<form action=\"rearranca_pcv_usuario.php\" method=post>";
    echo "Identificador corto del usuario (3 letras y 1 numero) ";
    echo "<input type=\"text\" name=\"usuario\" size =\"4\" value=\"\">";
    echo "<br><br><input type=\"submit\"  value=\" Rearrancar el PCV del usuario en VMWARE \">";
    echo "</form>";

}

pie_barra_menu();


?>

