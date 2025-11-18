<?php
// api/index.php - Punto de entrada principal
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Manejar preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'config.php';
require_once 'models/Database.php';
require_once 'models/UserModel.php';
require_once 'models/SyncModel.php';

try {
    $db = new Database();
    $pdo = $db->connect();
    
    // Obtener método y acción
    $method = $_SERVER['REQUEST_METHOD'];
    $action = $_GET['action'] ?? '';
    $table = $_GET['table'] ?? '';
    
    // Autenticación (excepto para login)
    if ($action !== 'login' && $action !== 'register') {
        $userModel = new UserModel($pdo);
        if (!$userModel->validateToken()) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            exit();
        }
    }
    
    // Enrutamiento
    switch ($action) {
        case 'login':
            require 'auth.php';
            handleLogin($pdo);
            break;
            
        case 'sync':
            require 'sync.php';
            handleSync($pdo, $method, $table);
            break;
            
        case 'backup':
            handleBackup($pdo);
            break;
            
        case 'restore':
            handleRestore($pdo);
            break;
            
        default:
            http_response_code(404);
            echo json_encode(['error' => 'Acción no encontrada']);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Error del servidor: ' . $e->getMessage()]);
}
?>