<?
require("lib/conf.inc");
$titulo = "GEISER";
top_barra_menu();
if ($nivel < 3) { echo '<h2><font color=#ff0000>Usted no tiene autorizaci&oacute;n para utilizar esta aplicaci&oacute;n </font></h2>'; exit;}

$equipo=getParametro('equipo');
$paquete=getParametro('paquete');
$pattern = "/^([A-Za-z0-9-.])*$/";
$cumple = preg_match($pattern,$equipo);
if ($paquete == 17) { $equipo = "VPRINT";}
if (($equipo != '') & ($cumple)) {
	switch ($paquete) {
	case 1:
		$package = "Uninstall_AuthPoint";
		break;
	case 2:
		$package = "AuthPoint";
		break;
	case 3:
		$package = "PDFXChange_licencia";
		break;
	case 4:
		$package = "ScandAll";
		break;
	case 5:
		$package = "Upgrade_W11";
		break;
	case 6:
		$package = "Paquetes_iniciales_APD";
		break;
	case 7:
		$package = "Paquetes_iniciales_TICNOVA";
		break;
	case 8:
		$package = "Paquetes_iniciales_PT";
		break;
	case 9:
		$package = "Portatil_Fase3";
		break;
	case 10:
		$package = "Script_Todas_Impresoras";
		break;
	case 11:
		$package = "Ganes";
		break;
	case 12:
		$package = "ipconfig_flushdns";
		break;
	case 13:
		$package = "Teams";
		break;
	case 14:
		$package = "Visdoc";
		break;
	case 15:
		$package = "CS6_Completo";
		break;
	case 16:
		$package = "Tarjetas_Dorlet";
		break;
	case 17:
		$package = "Reiniciar_servicio_impresoras";
		break;
	case 18:
		$package = "Autofirma";
		break;
	default:
		echo "<BR><BR>\n";
		echo "Por favor, seleccione una de las opciones disponibles.";
		exit;
	}
	echo "<h1>DesplegarAplicacion</h1>";
	echo "<BR>";
	$pass=descifra_simple($CFG->ADadminpwd);
	$comando="PDQDeploy deploy -Package $package -Targets $equipo";
	$salida=shell_exec("export SSHPASS=$pass ; sshpass -e ssh $CFG->ADadmin@deploy \"$comando\" 2>&1 ");
	echo "Resultado del despliegue:<BR>";
	echo "Comando:<B>$comando</B><BR>";
	echo "<PRE>";
	echo($salida);
	echo "</PRE>";
	echo "<BR><BR>\n";
} elseif (!($cumple)){
	echo "<BR><BR>\n";
	echo "Por favor, introduzca un nombre de equipo correcto.";
	exit;
} else {
	echo "<BR><BR>\n";
	echo "<B>IMPORTANTE:</B> Asegurese que el equipo responde a ping.";
	echo "<BR><BR>\n";
	echo "<form action=\"desplegar_aplicacion.php\" method=post>";
    echo "Nombre del equipo ";
    echo "<input type=\"text\" name=\"equipo\" size =\"13\" value=\"\">";
    echo "<br><br>Paquete a desplegar<br><br>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"1\"/> Desinstalar Agente MFA Authpoint<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"2\"/> Instalar Agente MFA Authpoint<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"3\"/> Instalar licencia PDF-XChange<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"4\"/> Instalar ScandAll PRO<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"5\"/> Actualizar a Windows 11<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"18\"/> Reinstalar Autofirma<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"6\"/> Desplegar Paquetes iniciales APD <br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"7\"/> Desplegar Paquetes iniciales TICNOVA <br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"8\"/> Desplegar Paquetes iniciales PORTATIL <br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"9\"/> Preparar Port&aacute;til FASE3 (usar su ip 10.14.142.x)<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"10\"/> Ejecutar Script de impresoras<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"11\"/> Instalar Programa Ganes<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"12\"/> Ipconfig FlushDNS<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"13\"/> Instalar Teams<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"14\"/> Instalar VisDOC<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"15\"/> Instalar CS6 Completo<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"16\"/> Instalar Programa Tarjetas Dorlet<br/>";
    echo "<input type=\"radio\" name=\"paquete\" value=\"17\"/> Reiniciar cola del servidor de impresoras<br/>";
    echo "<br><br><input type=\"submit\"  value=\" Ejecutar \">";
    echo "</form>";
}

pie_barra_menu();
?>
