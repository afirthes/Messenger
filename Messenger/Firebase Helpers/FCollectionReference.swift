//
//  FCollectionReference.swift
//  Messenger
//
//  Created by Afir Thes on 15.01.2022.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
}

func firebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    
    return Firestore.firestore().collection(collectionReference.rawValue)
}
