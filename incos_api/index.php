<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Manejar preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$request_uri = $_SERVER['REQUEST_URI'];
$base_path = '/incos_api/';

// Remover base path
$path = str_replace($base_path, '', $request_uri);
$path = strtok($path, '?');

// Enrutamiento simple
switch ($path) {
    case 'estudiantes':
        require_once 'controllers/EstudianteController.php';
        break;
    case 'asistencias':
        require_once 'controllers/AsistenciaController.php';
        break;
    case 'sync':
        require_once 'sync/SincronizacionController.php';
        break;
    case 'test':
        echo json_encode(array("success" => true, "message" => "API INCOS CHECK funcionando", "timestamp" => date('Y-m-d H:i:s')));
        break;
    default:
        http_response_code(404);
        echo json_encode(array("success" => false, "message" => "Endpoint no encontrado"));
        break;
}
?>