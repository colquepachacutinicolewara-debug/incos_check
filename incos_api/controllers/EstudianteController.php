<?php
require_once '../models/EstudianteModel.php';

class EstudianteController {
    private $estudianteModel;

    public function __construct() {
        $this->estudianteModel = new EstudianteModel();
    }

    // MANEJAR todas las solicitudes
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
                case 'PUT':
                    $this->handlePut();
                    break;
                case 'DELETE':
                    $this->handleDelete();
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
        if (isset($_GET['id'])) {
            $estudiante = $this->estudianteModel->obtenerPorId($_GET['id']);
            if ($estudiante) {
                echo json_encode(array("success" => true, "data" => $estudiante));
            } else {
                http_response_code(404);
                echo json_encode(array("success" => false, "message" => "Estudiante no encontrado"));
            }
        } else {
            $estudiantes = $this->estudianteModel->obtenerTodos();
            echo json_encode(array("success" => true, "data" => $estudiantes));
        }
    }

    private function handlePost() {
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (isset($input['estudiantes'])) {
            // Sincronización en lote
            $result = $this->estudianteModel->sincronizarLote($input['estudiantes']);
            echo json_encode($result);
        } else {
            // Crear individual
            $result = $this->estudianteModel->crear($input);
            echo json_encode($result);
        }
    }

    private function handlePut() {
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($_GET['id'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "ID requerido"));
            return;
        }

        $result = $this->estudianteModel->actualizar($_GET['id'], $input);
        echo json_encode($result);
    }

    private function handleDelete() {
        if (!isset($_GET['id'])) {
            http_response_code(400);
            echo json_encode(array("success" => false, "message" => "ID requerido"));
            return;
        }

        $result = $this->estudianteModel->eliminar($_GET['id']);
        echo json_encode($result);
    }
}

// Ejecutar controlador
$controller = new EstudianteController();
$controller->handleRequest();
?>