const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Función para asignar rol de ADMIN a un usuario
exports.assignAdminRole = functions.https.onCall(async (data, context) => {
  // Verificar que el usuario que llama es admin
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Usuario no autenticado"
    );
  }

  const callerUid = context.auth.uid;
  const targetUid = data.uid;

  // Verificar si el caller es admin
  const callerUser = await admin.auth().getUser(callerUid);
  if (!callerUser.customClaims || callerUser.customClaims.role !== "admin") {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Solo administradores pueden asignar roles"
    );
  }

  try {
    // Asignar rol de admin al usuario objetivo
    await admin.auth().setCustomUserClaims(targetUid, {
      role: "admin",
      createdAt: new Date().toISOString()
    });

    // Actualizar datos en Firestore también
    await admin.firestore().collection("users").doc(targetUid).set({
      role: "admin",
      email: data.email || "",
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return {
      success: true,
      message: `Rol de ADMIN asignado al usuario ${targetUid}`
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
  const callerUser = await admin.auth().getUser(callerUid);
  if (!callerUser.customClaims || callerUser.customClaims.role !== "admin") {
    throw new functions.https.HttpsError("permission-denied", "Solo administradores");
  }

  try {
    // Asignar rol de user normal
    await admin.auth().setCustomUserClaims(targetUid, {
      role: "user"
    });

    await admin.firestore().collection("users").doc(targetUid).set({
      role: "user",
      email: data.email || "",
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return {
      success: true,
      message: `Rol de USER asignado al usuario ${targetUid}`
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
    return {
      uid: uid,
      role: user.customClaims?.role || "user",
      email: user.email
    };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// Función para hacer admin al primer usuario (setup inicial)
exports.makeFirstUserAdmin = functions.auth.user().onCreate(async (user) => {
  try {
    // Verificar si es el primer usuario
    const users = await admin.auth().listUsers(2); // Solo traer 2 usuarios
    
    if (users.users.length === 1) {
      // Es el primer usuario, hacerlo admin
      await admin.auth().setCustomUserClaims(user.uid, {
        role: "admin"
      });
      
      // Guardar en Firestore
      await admin.firestore().collection("users").doc(user.uid).set({
        role: "admin",
        email: user.email,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log(`Usuario ${user.email} asignado como ADMIN (primer usuario)`);
    }
  } catch (error) {
    console.error("Error en makeFirstUserAdmin:", error);
  }
});