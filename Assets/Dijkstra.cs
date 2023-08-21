using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Experimental.GlobalIllumination;

namespace AAI.DIJKSTRA
{
    public class Dijkstra : MonoBehaviour
    {
        public Node StartNode;
        public Node GoalNode;

        protected Node[] _nodesInScene;

        protected void GetAllNodes()
        {
            _nodesInScene = FindObjectsOfType<Node>();
        }
        public List<Node> FindShortestPath(Node start, Node goal)
        {
            GetAllNodes();

            if (RunAlgorithm(start, goal))
            {
                List<Node> results = new List<Node>();
                Node current = goal;

                do
                {
                    results.Insert(0, current);
                    current = current.PreviousNode;
                } while (current != null);

                return results;
            }

            return null;
        }
        
        protected bool RunAlgorithm(Node start, Node goal)
        {
            return false;
        }
    }
}