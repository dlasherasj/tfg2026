<?

require("lib/conf.inc");
$titulo = "Gestión de Usuarios de Windows";

top_barra_menu();

if ($nivel < 1) { echo '<h2><font color=#ff0000>Usted no tiene autorizaci&oacute;n para utilizar esta aplicaci&oacute;n </font></h2>'; exit;}

$usuario=getParametro('usuario');

echo "<h1>Arranque del PCV personal en VMWARE ESXi</h1>"; 

echo "<BR>";


echo "<B>Si todo va bien, el primer arranque puede tardar unos 5 minutos aprox, ya que implica rearranque, inscripcion en el dominio, etc... <BR>";

echo "<BR>\n";

echo "ENJOY !!!";

echo "<BR><BR>\n";

echo "<B>Arrancando el PCV via PowerShell...</B><BR>";
echo "<BR>\n";

ob_flush();
flush();

$ruta_scripts = "/scripts/";
$pcv="PCV-".strtoupper($usuario);
$current_user = trim(shell_exec('whoami'));

$comando="export HOME=/home/$current_user; pwsh -Command $ruta_scripts/vm_start_vm.ps1 $pcv ";
$salida=shell_exec("$comando 2>&1 ");

echo "Resultado del arranque del PCV en ESXi:<BR>";
echo "Comando:<B>$comando</B><BR>";
echo "<PRE>";
echo($salida);
echo "</PRE>";

pie_barra_menu();


?>


