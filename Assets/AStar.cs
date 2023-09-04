using System.Collections.Generic;
using UnityEngine;

namespace AAI.DIJKSTRA
{
    public class AStar : Dijkstra
    {
        protected override void Start()
        {
            foreach (Node nodeInScene in _nodesInScene)
            {
                nodeInScene.SetUpHeuristic(GoalNode.transform.position);
            }

            base.Start();
        }

        protected override bool RunAlgorithm(Node start, Node goal)
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
                unexplored.Sort((a, b) => a.PathHeuristicWeight.CompareTo(b.PathHeuristicWeight));

                Node current = unexplored[0];
                unexplored.RemoveAt(0);

                foreach (Node neighbourNode in current.Neighbours)
                {
                    //Only explore unexplored nodes
                    if (!unexplored.Contains(neighbourNode))
                    {
                        continue;
                    }

                    float neighbourWeight = Vector3.Distance(current.transform.position,
                        neighbourNode.transform.position);
                    neighbourWeight += current.PathWeight;
                    // neighbourWeight += penalty;
                    /*
                    neighbourWeight +=  Vector3.Distance(goalNode.transform.position,
                        neighbourNode.transform.position);
                        */
                    if (neighbourWeight < neighbourNode.PathWeight)
                    {
                        neighbourNode.PathWeight = neighbourWeight;
                        neighbourNode.PreviousNode = current;
                    }
                }

                if (current == goalNode)
                {
                    return true;
                }
            }

            return false;
        }
    }
}