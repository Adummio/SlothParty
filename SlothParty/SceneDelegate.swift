//
//  SceneDelegate.swift
//  SlothParty
//
//  Created by Massimo Maddaluno on 05/05/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        
        var rootVC : UIViewController
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if JsonManager.shared.loadJson(){
            rootVC = storyboard.instantiateViewController(identifier: "TabBarVC")
            
            print("Json exists and it's setted to true")
            
            JsonManager.shared.loadUser {
                
                //I dunno if this is the properly way to load the view only
                //when the user info are retrieved
                
                DispatchQueue.main.async {
                    self.window?.rootViewController = rootVC
                    self.window?.makeKeyAndVisible()
                }
            }
            
        }
        else{
            print("Json file not found/is false")
            
            rootVC = storyboard.instantiateViewController(identifier: "TabBarVC")
            
            self.window?.rootViewController = rootVC
            self.window?.makeKeyAndVisible()
            
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

