//
//  ViewController.swift
//  ARDice
//
//  Created by eren on 2.08.2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var arryDice = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Open debug options for feature points
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Enable Auto Lightning
        sceneView.autoenablesDefaultLighting = true
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func roll(dice: SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 5),
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5
        ))
    }
    
    func rollAll() {
        if !arryDice.isEmpty{
            for dice in arryDice{
                roll(dice:dice)
            }
        }
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    @IBAction func removeAllDices(_ sender: UIBarButtonItem) {
        if !arryDice.isEmpty{
            for dice in arryDice{
                dice.removeFromParentNode()
            }
            arryDice.removeAll()
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
        
        let plane = SCNPlane(width: CGFloat(anchorPlane.extent.x), height: CGFloat(anchorPlane.extent.z))
        
        let nodePlane = SCNNode()
        
        nodePlane.position = SCNVector3(anchorPlane.center.x, 0, anchorPlane.center.z)
        
        nodePlane.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let materialGrid = SCNMaterial()
        
        materialGrid.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [materialGrid]
        
        nodePlane.geometry = plane
        
        node.addChildNode(nodePlane)
        
        //OR (has position dedection problem)
        //            sceneView.scene.rootNode.addChildNode(nodePlane)
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let locationTouch = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(locationTouch, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first{
                addDice(atLocation: hitResult)
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult){
        
        // Create a new scene
        let sceneDice = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let nodeDice = sceneDice.rootNode.childNode(withName: "Dice", recursively: true){
            
            nodeDice.position = SCNVector3(
                location.worldTransform.columns.3.x,
                location.worldTransform.columns.3.y,
                location.worldTransform.columns.3.z
            )
            
            //        // Set the scene to the view
            //        sceneView.scene = sceneDice
            
            arryDice.append(nodeDice)
            
            //OR CHECK PERFORMANCE AFFECT
            sceneView.scene.rootNode.addChildNode(nodeDice)
            
            roll(dice: nodeDice)
            
        }
    }
    
    
}
