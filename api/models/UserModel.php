<?php
// api/models/UserModel.php - Manejo de usuarios y autenticación
class UserModel {
    private $pdo;
    
    public function __construct($pdo) {
        $this->pdo = $pdo;
    }
    
    public function login($username, $password) {
        $stmt = $this->pdo->prepare("
            SELECT id, username, email, nombre, role, password, esta_activo 
            FROM usuarios 
            WHERE username = ? AND esta_activo = 1
        ");
        $stmt->execute([$username]);
        $user = $stmt->fetch();
        
        if ($user && password_verify($password, $user['password'])) {
            // Generar token JWT
            $token = $this->generateToken($user);
            
            // Registrar log de acceso
            $this->logAccess($user['id'], 'LOGIN', 'Inicio de sesión exitoso');
            
            return [
                'success' => true,
                'token' => $token,
                'user' => [
                    'id' => $user['id'],
                    'username' => $user['username'],
                    'email' => $user['email'],
                    'nombre' => $user['nombre'],
                    'role' => $user['role']
                ]
            ];
        }
        
        return ['success' => false, 'message' => 'Credenciales incorrectas'];
    }
    
    public function validateToken() {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? '';
        
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            $token = $matches[1];
            return $this->verifyToken($token);
        }
        
        return false;
    }
    
    private function generateToken($user) {
        $payload = [
            'iss' => 'incos_check_api',
            'aud' => 'incos_check_app',
            'iat' => time(),
            'exp' => time() + Config::JWT_EXPIRE,
            'data' => [
                'userId' => $user['id'],
                'username' => $user['username'],
                'role' => $user['role']
            ]
        ];
        
        return JWT::encode($payload, Config::JWT_SECRET, 'HS256');
    }
    
    private function verifyToken($token) {
        try {
            $decoded = JWT::decode($token, Config::JWT_SECRET, ['HS256']);
            return (array) $decoded->data;
        } catch (Exception $e) {
            return false;
        }
    }
    
    private function logAccess($userId, $action, $details) {
        $stmt = $this->pdo->prepare("
            INSERT INTO logs_seguridad (id, usuario_id, modulo, accion, tipo, detalles, ip, dispositivo)
            VALUES (?, ?, 'AUTH', ?, 'INFO', ?, ?, ?)
        ");
        
        $logId = uniqid('log_', true);
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $device = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
        
        $stmt->execute([$logId, $userId, $action, $details, $ip, $device]);
    }
}

// Clase simple para JWT (en producción usar una librería como firebase/php-jwt)
class JWT {
    public static function encode($payload, $key, $alg = 'HS256') {
        $header = json_encode(['typ' => 'JWT', 'alg' => $alg]);
        $payload = json_encode($payload);
        
        $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
        
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, $key, true);
        $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
        
        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }
    
    public static function decode($jwt, $key, $allowed_algs = ['HS256']) {
        $tokens = explode('.', $jwt);
        if (count($tokens) != 3) {
            throw new Exception('Token inválido');
        }
        
        list($header, $payload, $signature) = $tokens;
        
        // Verificar firma
        $verified_signature = hash_hmac('sha256', $header . "." . $payload, $key, true);
        $verified_signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($verified_signature));
        
        if ($signature !== $verified_signature) {
            throw new Exception('Firma inválida');
        }
        
        $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $payload)), true);
        
        // Verificar expiración
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            throw new Exception('Token expirado');
        }
        
        return $payload;
    }
}
?>