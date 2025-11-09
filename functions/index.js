const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Función para asignar rol de ADMIN a un usuario
exports.assignAdminRole = functions.https.onCall(async (data, context) => {
  // Verificar que el usuario que llama está autenticado
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Usuario no autenticado"
    );
  }

  const callerUid = context.auth.uid;
  const targetUid = data.uid;

  // Verificar si el caller es admin
  try {
    const callerUser = await admin.auth().getUser(callerUid);
    if (!callerUser.customClaims || callerUser.customClaims.role !== "admin") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Solo administradores pueden asignar roles"
      );
    }

    // Asignar rol de admin al usuario objetivo
    await admin.auth().setCustomUserClaims(targetUid, {
      role: "admin",
      assignedBy: callerUid,
      assignedAt: new Date().toISOString()
    });

    // Actualizar datos en Firestore también
    await admin.firestore().collection("users").doc(targetUid).set({
      role: "admin",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: callerUid
    }, { merge: true });

    return {
      success: true,
      message: `✅ Rol de ADMIN asignado al usuario ${targetUid}`,
      uid: targetUid
    };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// Función para asignar rol de USER normal
exports.assignUserRole = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Usuario no autenticado");
  }

  const callerUid = context.auth.uid;
  const targetUid = data.uid;

  // Verificar si el caller es admin
  try {
    const callerUser = await admin.auth().getUser(callerUid);
    if (!callerUser.customClaims || callerUser.customClaims.role !== "admin") {
      throw new functions.https.HttpsError("permission-denied", "Solo administradores pueden asignar roles");
    }

    // Asignar rol de user normal
    await admin.auth().setCustomUserClaims(targetUid, {
      role: "user"
    });

    await admin.firestore().collection("users").doc(targetUid).set({
      role: "user",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: callerUid
    }, { merge: true });

    return {
      success: true,
      message: `✅ Rol de USER asignado al usuario ${targetUid}`,
      uid: targetUid
    };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// Función para obtener el rol del usuario actual
exports.getUserRole = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Usuario no autenticado");
  }

  const uid = context.auth.uid;

  try {
    const user = await admin.auth().getUser(uid);
    const userDoc = await admin.firestore().collection("users").doc(uid).get();
    
    return {
      uid: uid,
      role: user.customClaims?.role || "user",
      email: user.email,
      firestoreData: userDoc.exists ? userDoc.data() : null
    };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// Función para listar todos los usuarios (solo admins)
exports.listUsers = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Usuario no autenticado");
  }

  const callerUid = context.auth.uid;

  // Verificar si el caller es admin
  try {
    const callerUser = await admin.auth().getUser(callerUid);
    if (!callerUser.customClaims || callerUser.customClaims.role !== "admin") {
      throw new functions.https.HttpsError("permission-denied", "Solo administradores pueden listar usuarios");
    }

    const users = await admin.auth().listUsers();
    const usersWithRoles = await Promise.all(
      users.users.map(async (userRecord) => {
        const userDoc = await admin.firestore().collection("users").doc(userRecord.uid).get();
        return {
          uid: userRecord.uid,
          email: userRecord.email,
          displayName: userRecord.displayName,
          role: userRecord.customClaims?.role || "user",
          firestoreData: userDoc.exists ? userDoc.data() : null,
          createdAt: userRecord.metadata.creationTime,
          lastSignIn: userRecord.metadata.lastSignInTime
        };
      })
    );

    return {
      success: true,
      users: usersWithRoles
    };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// Función para hacer admin al primer usuario (útil para inicialización)
exports.makeFirstUserAdmin = functions.https.onRequest(async (req, res) => {
  try {
    const users = await admin.auth().listUsers(1);
    
    if (users.users.length === 0) {
      return res.status(400).json({ error: "No hay usuarios en el sistema" });
    }

    const firstUser = users.users[0];
    
    await admin.auth().setCustomUserClaims(firstUser.uid, {
      role: "admin",
      isInitialAdmin: true,
      assignedAt: new Date().toISOString()
    });

    await admin.firestore().collection("users").doc(firstUser.uid).set({
      role: "admin",
      isInitialAdmin: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    res.json({
      success: true,
      message: `✅ Usuario ${firstUser.email} ahora es ADMIN`,
      user: {
        uid: firstUser.uid,
        email: firstUser.email,
        role: "admin"
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});