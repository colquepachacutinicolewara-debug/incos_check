<?php
require_once '../config/database.php';

class EstudianteModel {
    private $conn;
    private $table_name = "estudiantes";

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // CREAR estudiante
    public function crear($data) {
        $query = "INSERT INTO " . $this->table_name . " 
                  (id, nombres, apellido_paterno, apellido_materno, ci, fecha_registro, 
                   huellas_registradas, carrera_id, turno_id, nivel_id, paralelo_id, activo) 
                  VALUES (:id, :nombres, :apellido_paterno, :apellido_materno, :ci, :fecha_registro, 
                          :huellas_registradas, :carrera_id, :turno_id, :nivel_id, :paralelo_id, :activo)";

        $stmt = $this->conn->prepare($query);

        // Bind parameters
        $stmt->bindParam(":id", $data['id']);
        $stmt->bindParam(":nombres", $data['nombres']);
        $stmt->bindParam(":apellido_paterno", $data['apellido_paterno']);
        $stmt->bindParam(":apellido_materno", $data['apellido_materno']);
        $stmt->bindParam(":ci", $data['ci']);
        $stmt->bindParam(":fecha_registro", $data['fecha_registro']);
        $stmt->bindParam(":huellas_registradas", $data['huellas_registradas']);
        $stmt->bindParam(":carrera_id", $data['carrera_id']);
        $stmt->bindParam(":turno_id", $data['turno_id']);
        $stmt->bindParam(":nivel_id", $data['nivel_id']);
        $stmt->bindParam(":paralelo_id", $data['paralelo_id']);
        $stmt->bindParam(":activo", $data['activo']);

        try {
            if ($stmt->execute()) {
                return array("success" => true, "message" => "Estudiante creado", "id" => $data['id']);
            }
        } catch (PDOException $e) {
            if ($e->getCode() == 23000) { // Duplicado
                return $this->actualizar($data['id'], $data);
            }
            return array("success" => false, "message" => "Error: " . $e->getMessage());
        }
        return array("success" => false, "message" => "Error desconocido");
    }

    // ACTUALIZAR estudiante
    public function actualizar($id, $data) {
        $query = "UPDATE " . $this->table_name . " 
                  SET nombres = :nombres, apellido_paterno = :apellido_paterno, 
                      apellido_materno = :apellido_materno, ci = :ci, 
                      huellas_registradas = :huellas_registradas, carrera_id = :carrera_id,
                      turno_id = :turno_id, nivel_id = :nivel_id, paralelo_id = :paralelo_id,
                      activo = :activo, fecha_actualizacion = CURRENT_TIMESTAMP
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":id", $id);
        $stmt->bindParam(":nombres", $data['nombres']);
        $stmt->bindParam(":apellido_paterno", $data['apellido_paterno']);
        $stmt->bindParam(":apellido_materno", $data['apellido_materno']);
        $stmt->bindParam(":ci", $data['ci']);
        $stmt->bindParam(":huellas_registradas", $data['huellas_registradas']);
        $stmt->bindParam(":carrera_id", $data['carrera_id']);
        $stmt->bindParam(":turno_id", $data['turno_id']);
        $stmt->bindParam(":nivel_id", $data['nivel_id']);
        $stmt->bindParam(":paralelo_id", $data['paralelo_id']);
        $stmt->bindParam(":activo", $data['activo']);

        if ($stmt->execute()) {
            return array("success" => true, "message" => "Estudiante actualizado");
        }
        return array("success" => false, "message" => "Error al actualizar");
    }

    // OBTENER todos los estudiantes
    public function obtenerTodos() {
        $query = "SELECT * FROM " . $this->table_name . " WHERE activo = 1 ORDER BY apellido_paterno, apellido_materno, nombres";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    // OBTENER por ID
    public function obtenerPorId($id) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        return $stmt->fetch();
    }

    // ELIMINAR estudiante (soft delete)
    public function eliminar($id) {
        $query = "UPDATE " . $this->table_name . " SET activo = 0 WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $id);
        
        if ($stmt->execute()) {
            return array("success" => true, "message" => "Estudiante eliminado");
        }
        return array("success" => false, "message" => "Error al eliminar");
    }

    // SINCRONIZAR múltiples estudiantes
    public function sincronizarLote($estudiantes) {
        $results = array();
        
        foreach ($estudiantes as $estudiante) {
            $result = $this->crear($estudiante);
            $results[] = array(
                'id' => $estudiante['id'],
                'success' => $result['success'],
                'message' => $result['message']
            );
        }
        
        return array("success" => true, "results" => $results);
    }
}
?>