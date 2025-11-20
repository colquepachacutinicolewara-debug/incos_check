<?php
require_once '../models/EstudianteModel.php';
require_once '../models/AsistenciaModel.php';

class SincronizacionController {
    private $estudianteModel;
    private $asistenciaModel;

    public function __construct() {
        $this->estudianteModel = new EstudianteModel();
        $this->asistenciaModel = new AsistenciaModel();
    }

    public function handleRequest() {
        $method = $_SERVER['REQUEST_METHOD'];
        header('Content-Type: application/json');

        if ($method !== 'POST') {
            http_response_code(405);
            echo json_encode(array("success" => false, "message" => "Método no permitido"));
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);
        
        $results = array(
            'estudiantes' => array(),
            'asistencias' => array(),
            'timestamp' => date('Y-m-d H:i:s')
        );

        // Sincronizar estudiantes
        if (isset($input['estudiantes']) && is_array($input['estudiantes'])) {
            $resultEstudiantes = $this->estudianteModel->sincronizarLote($input['estudiantes']);
            $results['estudiantes'] = $resultEstudiantes;
        }

        // Sincronizar asistencias
        if (isset($input['asistencias']) && is_array($input['asistencias'])) {
            $resultAsistencias = $this->asistenciaModel->sincronizarLote($input['asistencias']);
            $results['asistencias'] = $resultAsistencias;
        }

        echo json_encode(array("success" => true, "data" => $results));
    }
}

// Ejecutar controlador
$controller = new SincronizacionController();
$controller->handleRequest();
?>