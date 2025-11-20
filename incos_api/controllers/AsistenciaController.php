<?php
require_once '../models/AsistenciaModel.php';

class AsistenciaController {
    private $asistenciaModel;

    public function __construct() {
        $this->asistenciaModel = new AsistenciaModel();
    }

    public function handleRequest() {
        $method = $_SERVER['REQUEST_METHOD'];
        header('Content-Type: application/json');

        try {
            switch ($method) {
                case 'GET':
                    $this->handleGet();
                    break;
                case 'POST':
                    $this->handlePost();
                    break;
                default:
                    http_response_code(405);
                    echo json_encode(array("success" => false, "message" => "Método no permitido"));
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error: " . $e->getMessage()));
        }
    }

    private function handleGet() {
        if (isset($_GET['fecha'])) {
            $materia_id = isset($_GET['materia_id']) ? $_GET['materia_id'] : null;
            $asistencias = $this->asistenciaModel->obtenerPorFecha($_GET['fecha'], $materia_id);
            echo json_encode(array("success" => true, "data" => $asistencias));
        } else {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "Parámetro fecha requerido"));
        }
    }

    private function handlePost() {
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (isset($input['asistencias'])) {
            // Sincronización en lote
            $result = $this->asistenciaModel->sincronizarLote($input['asistencias']);
            echo json_encode($result);
        } else {
            // Registrar individual
            $result = $this->asistenciaModel->registrar($input);
            echo json_encode($result);
        }
    }
}

// Ejecutar controlador
$controller = new AsistenciaController();
$controller->handleRequest();
?>