using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using Debug = UnityEngine.Debug;

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

        void Start()
        {
            //RunAndDisplayPath();
            RunXTimes(100);
        }

        public void RunXTimes(int x)
        {
            Stopwatch sw = new Stopwatch();
            sw.Start();
            for(int loop = 0; loop < x; loop++)
            {
                FindShortestPath(StartNode, GoalNode);
            }
            sw.Stop();

            Debug.Log(sw.ElapsedMilliseconds.ToString());
        }

        public void RunAndDisplayPath()
        {
            List<Node> path = FindShortestPath(StartNode, GoalNode);

            for(int index = 0; index < path.Count - 1 ;index++)
            {
                Debug.DrawLine(path[index].transform.position + Vector3.up,
                               path[index + 1].transform.position + Vector3.up,
                               Color.green, 10f);

                Debug.Log(path[index].name);
            }
            Debug.Log(path[path.Count -1].name);
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
            List<Node> unexplored = new List<Node>();

            Node startNode = null;
            Node goalNode = null;

            foreach (Node nodeInScene in _nodesInScene)
            {
                nodeInScene.ResetNode();
                unexplored.Add(nodeInScene);

                //check for start and end node
                if (start == nodeInScene)
                {
                    startNode = nodeInScene;
                }
                if (goal == nodeInScene)
                {
                    goalNode = nodeInScene;
                }
            }
            //if we cant find start or end node, then we cant find a path
            if (startNode == null || goalNode == null)
            {
                return false;
            }

            startNode.PathWeight = 0;
            while (unexplored.Count > 0)
            {
                unexplored.Sort( (a, b) => a.PathWeight.CompareTo(b.PathWeight) );

                Node current = unexplored[0];
                unexplored.RemoveAt(0);

                foreach(Node neighbourNode in current.Neighbours)
                {
                    //Only explore unexplored nodes
                    if(!unexplored.Contains(neighbourNode))
                    {
                        continue;
                    }

                    float neighbourWeight = Vector3.Distance(current.transform.position,
                                                            neighbourNode.transform.position);
                    neighbourWeight += current.PathWeight;
                   // neighbourWeight += penalty;

                    if(neighbourWeight < neighbourNode.PathWeight)
                    {
                        neighbourNode.PathWeight = neighbourWeight;
                        neighbourNode.PreviousNode = current;
                    }
                }
                if(current == goalNode)
                {
                    return true;
                }
            }
            return false;
        }
    }
}