using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace AAI.DFS
{
    public class Node
    {
        public int data; //Store this data
        public Node left;
        public Node right;

        public Node(int item)
        {
            data = item;
            left = null;
            right = null;
        }
    }

    public class DepthFirstSearch : MonoBehaviour
    {
        public Node root;

        void Start()
        {
            root = new Node(0);
            root.left = new Node(1);
            root.right = new Node(2);
            root.left.left = new Node(3);
            root.left.right = new Node(4);

            PrintInPostOrder(root);
        }

        void PrintInOrder(Node node)
        {
            if (node == null)
            {
                return;
            }

            PrintInOrder(node.left);

            Debug.Log(node.data);

            PrintInOrder(node.right);

        }

        void PrintInPreOrder(Node node)
        {
            if (node == null)
            {
                return;
            }

            Debug.Log(node.data);
            PrintInPreOrder(node.left);
            PrintInPreOrder(node.right);

        }

        void PrintInPostOrder(Node node)
        {
            if (node == null)
            {
                return;
            }

            PrintInPostOrder(node.left);
            PrintInPostOrder(node.right);
            Debug.Log(node.data);

        }


    }
}
