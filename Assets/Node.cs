using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Unity.VisualScripting;
using UnityEngine;

namespace AAI.DIJKSTRA
{
    public class Node : MonoBehaviour
    {
        public List<Node> Neighbours;
        private float _pathWeight = float.PositiveInfinity;
        
        private Node _previousNode;
        public Node PreviousNode
        {
            get => _previousNode;
            set => _previousNode = value;
        }

        public void ResetNode()
        {
            _pathWeight = float.PositiveInfinity;
            _previousNode = null;
        }

        private void OnValidate() => ValidateNeighbours();
        

        private void ValidateNeighbours() 
        {
            foreach (Node waypoint in Neighbours)
            {
                if (waypoint == null) continue;

                if (!waypoint.Neighbours.Contains((this)))
                {
                    waypoint.Neighbours.Add(this);
                }
            }
        }

        private void OnDrawGizmos()
        {
            if(Neighbours == null) return;
            float radius = 0.2f;
            
            Gizmos.color = Color.blue;
            foreach (Node waypoint in Neighbours)
            {
                if(waypoint == null) continue;
                Gizmos.DrawLine(transform.position, waypoint.transform.position);
            }
            Gizmos.color = Color.red;
            Gizmos.DrawSphere(transform.position, radius);
        }
    }
}