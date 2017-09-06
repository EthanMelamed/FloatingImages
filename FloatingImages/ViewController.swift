//
//  ViewController.swift
//  FloatingImages
//
//  Created by Ethan  on 2017-09-05.
//  Copyright © 2017 Ethan . All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene();
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(ViewController.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:
            #selector(ViewController.handlePinch(gestureRecognize:)))
        view.addGestureRecognizer(pinchGesture)
    }
    
    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer){
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        //create an image plane using a snapshot of the view
        let imagePlane = SCNPlane(width: sceneView.bounds.width / 6000,
                                  height: sceneView.bounds.height / 6000)
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
        imagePlane.firstMaterial?.lightingModel = .constant
        
        //create a plane node and add it to the scene
        let planeNode = SCNNode(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        //Set transform of node to be 10cm in front of camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1
        planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
    }
    @objc
    func handlePinch(gestureRecognize: UIPinchGestureRecognizer){
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        if(gestureRecognize.state == UIGestureRecognizerState.ended){
            print("PINCH END");
        }
    }
    
    func printChildNode(node: SCNNode){
        print(node);
        node.childNodes.forEach { childNode in
            printChildNode(node: childNode);
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // This visualization covers only detected planes.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the node using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // SCNPlanes are vertically oriented in their local coordinate space.
        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)
        
        //create an image plane using a snapshot of the view
        let imagePlane = SCNPlane(width: plane.width,
                                  height: plane.height)
        imagePlane.firstMaterial?.diffuse.contents = UIColor.red;
        imagePlane.firstMaterial?.lightingModel = .constant
        sceneView.scene.rootNode.addChildNode(planeNode)
    }
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        if case .limited(let reason) = camera.trackingState {
            // notify user of limited tracking state
            // ...
        }
    }
}
