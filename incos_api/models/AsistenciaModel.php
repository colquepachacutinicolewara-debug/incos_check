<?php
require_once '../config/database.php';

class AsistenciaModel {
    private $conn;
    private $table_name = "asistencia_diaria";

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // REGISTRAR asistencia
    public function registrar($data) {
        $query = "INSERT INTO " . $this->table_name . " 
                  (id, estudiante_id, materia_id, horario_clase_id, fecha, periodo_numero,
                   estado, minutos_retraso, observaciones, usuario_registro) 
                  VALUES (:id, :estudiante_id, :materia_id, :horario_clase_id, :fecha, :periodo_numero,
                          :estado, :minutos_retraso, :observaciones, :usuario_registro) 
                  ON DUPLICATE KEY UPDATE 
                  estado = VALUES(estado), minutos_retraso = VALUES(minutos_retraso),
                  observaciones = VALUES(observaciones), usuario_registro = VALUES(usuario_registro)";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":id", $data['id']);
        $stmt->bindParam(":estudiante_id", $data['estudiante_id']);
        $stmt->bindParam(":materia_id", $data['materia_id']);
        $stmt->bindParam(":horario_clase_id", $data['horario_clase_id']);
        $stmt->bindParam(":fecha", $data['fecha']);
        $stmt->bindParam(":periodo_numero", $data['periodo_numero']);
        $stmt->bindParam(":estado", $data['estado']);
        $stmt->bindParam(":minutos_retraso", $data['minutos_retraso']);
        $stmt->bindParam(":observaciones", $data['observaciones']);
        $stmt->bindParam(":usuario_registro", $data['usuario_registro']);

        if ($stmt->execute()) {
            return array("success" => true, "message" => "Asistencia registrada", "id" => $data['id']);
        }
        return array("success" => false, "message" => "Error al registrar asistencia");
    }

    // OBTENER asistencias por fecha
    public function obtenerPorFecha($fecha, $materia_id = null) {
        $query = "SELECT ad.*, e.nombres, e.apellido_paterno, e.apellido_materno, e.ci
                  FROM " . $this->table_name . " ad
                  JOIN estudiantes e ON ad.estudiante_id = e.id
                  WHERE ad.fecha = :fecha";
        
        if ($materia_id) {
            $query .= " AND ad.materia_id = :materia_id";
        }
        
        $query .= " ORDER BY e.apellido_paterno, e.apellido_materno, e.nombres";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":fecha", $fecha);
        
        if ($materia_id) {
            $stmt->bindParam(":materia_id", $materia_id);
        }
        
        $stmt->execute();
        return $stmt->fetchAll();
    }

    // SINCRONIZAR múltiples asistencias
    public function sincronizarLote($asistencias) {
        $results = array();
        
        foreach ($asistencias as $asistencia) {
            $result = $this->registrar($asistencia);
            $results[] = array(
                'id' => $asistencia['id'],
                'success' => $result['success'],
                'message' => $result['message']
            );
        }
        
        return array("success" => true, "results" => $results);
    }
}
?>