<?
require("lib/conf.inc");
$titulo = "GestiÛn de Usuarios de windows";

top_barra_menu();

if ($nivel < 1) { echo '<h2><font color=#ff0000>Usted no tiene autorizaci&oacute;n para utilizar esta aplicaci&oacute;n </font></h2>'; exit;}

$ruta_perfiles = "\\\\filer\\WINVOL\\Perfiles\\";

$modif=getParametro('modif');
$numboe=getParametro('numboe');
$correo=getParametro('correo');
$mensaje="";

if ($modif)
{ 	echo "<h1>ModificaciÛn de Usuarios</h1>"; }
else
{ echo "<h1>Alta de Usuarios</h1>"; }

   $select_csv="select translate(csv, '·ÈÌÛ˙‡ËÏÚ˘„ı‚ÍÓÙÙ‰ÎÔˆ¸Á¡…Õ”⁄¿»Ã“Ÿ√’¬ Œ‘€ƒÀœ÷‹«', 'aeiouaeiouaoaeiooaeioucAEIOUAEIOUAOAEIOOAEIOUC') csv, lower(usuario) usuario from v_boe_usuarios_wincsv where numboe='$numboe' ";
   $query=db_query($conn,$select_csv);
          $resultado = db_fetch_array($query);
          $usuario=$resultado["USUARIO"];
	  $csv=$resultado["CSV"];
	//Quitamos comas (de los OUs) para que coincida con el almacenado en AD
	  $csv=str_replace(',','',$csv);


if (!$correo)
 
 { echo "<font color=RED>El fichero LDF no se puede generar sin una direcciÛn de correo</font>";
       exit; }

if ($usuario) { 

  // Formateo del LDF para cargarlo posteriormente con LDIFDE

  // Correcciones previas


  // Se pasa a mayuscula la primera letra de cada palabra
  $csv = ucwords($csv); 
  // Se arreglan las palabras cortas
  $csv = preg_replace('/ Y /', ' y ', $csv);
  $csv = preg_replace('/ E /', ' e ', $csv);
  $csv = preg_replace('/ De /', ' de ', $csv);
  $csv = preg_replace('/ Del /', ' del ', $csv);
  $csv = preg_replace('/ Con /', ' con ', $csv);
  $csv = preg_replace('/ La /', ' la ', $csv);


// USUARIO|NOMBRE|APELLIDOS|NOMPRES|NUMBOE|EXTENSION|DESPACHO|EXTMOVIL|FAX|EMAIL|DEPARTAMENTO|AREA|SERVICIO|SECCION|DNI_LET|NOMBPUES|UNIX_USERID|DEPTUNIX|UNIX_UID|UNIX_GID
//
// DLJ1|David|Las Heras JimÈnez|David Las Heras|999999|4444|O-222|5555||david.heras@boe.es|Departamento de TecnologÌas de la InformaciÛn|¡rea de Red BOE|Servicio de Sistemas Avanzados||444123456A|Analista de sistemas||Departamento de TecnologÌas de la InformaciÛn|7656|5000

  list($USUARIO,$NOMBRE,$APELLIDOS,$NOMPRES,$NUMBOE,$EXTENSION,$DESPACHO,$EXTMOVIL,$FAX,$EMAIL,$DEPARTAMENTO,$AREA,$SERVICIO,$SECCION,$DNI_LET,$NOMBPUES,$UNIX_USERID,$DEPTUNIX,$UNIX_UID,$UNIX_GID) = explode ("|", $csv);

  // Mas arreglos...

// Cambiamos el NOMPRES que viene de ORACLE por la concatenacion de NOMBRE y APELLIDOS
// David (12/07/2022)

$NOMPRES="$NOMBRE"." "."$APELLIDOS";

  $USUARIO=strtolower($USUARIO);                                                                                                                    
  $DNI_LET=strtoupper($DNI_LET);                                                                                                                    
  $EMAIL=strtolower($EMAIL);    

  $STRINGOU="OU=".$DEPARTAMENTO.",OU=Empleados,OU=BOE";                                                                                
  if ($AREA != "") {                                                                                                                    
    $STRINGOU="OU=$AREA,".$STRINGOU;                                                                                                    
  }                                                                                                                                         
  if ($SERVICIO != "") {                                                                                                                    
    $STRINGOU="OU=$SERVICIO,".$STRINGOU;                                                                                                    
  }                                                                                                                                         
  if ($SECCION != "") {                                                                                                                     
    $STRINGOU="OU=$SECCION,".$STRINGOU;                                                                                                     
  }                                  

// Workaround para evitar las diferencias del arbol de AD con el de RRHH
// Ponemos a todo el mundo inicialmente en la raiz del arbol de AD (OU=Empleados)
// David - 05/10/2022

$STRINGOU="OU=Empleados,OU=BOE"; 

  $ldf=<<<EOT
dn: CN=$NOMPRES,$STRINGOU,DC=boe,DC=int
changetype: add
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: $NOMPRES
sn: $APELLIDOS
givenName: $NOMBRE
distinguishedName: CN=$NOMPRES,$STRINGOU,DC=boe,DC=int
displayName: $NOMPRES
name: $NOMPRES
userAccountControl: 512
profilePath: $ruta_perfiles$USUARIO
sAMAccountName: $USUARIO
userPrincipalName: $EMAIL
mail: $EMAIL
countryCode: 724
co: Spain
c: ES
EOT;


  $path="/ldap/$usuario.ldf";

  $fichero = fopen("$path","w"); 
  fputs($fichero,$ldf); 
  fclose($fichero); 

  echo "Fichero generado correctamente.<BR><BR>";


echo "El contenido del fichero generado es:<BR><BR>";

echo "<PRE>";

 $salida=file_get_contents($path);
 print_r($salida);

echo "</PRE>";

echo "<BR>";


echo "<B>NOTA:</B> Si todo es correcto, puedes proceder a cargar dicho LDIF en AD, teniendo en cuenta que el usuario no debe existir previamente. Por tanto, si se ha realizado alguna carga previa del mismo usuario, es necesario su borrado via AD. En este caso, el identificador interno en Windows, cambiar·, por lo que dicho usuario perder· acceso a todos sus documentos previos, etc. Por tanto, solo deber· utilizarse esta vÌa si el usuario no tiene un historial previo. En caso contrario, mejor hacer las modificaciones sobre el objeto existente en AD, vÌa Windows.<BR><BR>";
echo "<B>NOTA 2:</B> Una vez creado el usuario en el AD, este aparecer· en la raiz del mismo (OU=Empleados). Es necesario mover dicho objeto usuario a su U definitiva. Esto se hace directamente con la herramienta de Windows <b>Usuarios y Equipos del Directorio Activo</b>.<BR><BR>";

    echo "<form action=\"crea_usuario_windows.php\" method=post>";
    echo "<br><br><input type=\"submit\"  value=\" Crear el usuario en el entorno WINDOWS \">";
    echo "<input type=\"hidden\" name=\"usuario\" value=\"$usuario\">";
    echo "</form>";


}


else

{
 echo "<font color=RED>Ha ocurrido un error. No se ha podido generar el fichero LDF. Consulte el estado del Num. Boe en el Directorio de Personal.</font>";
}


pie_barra_menu();

?>
