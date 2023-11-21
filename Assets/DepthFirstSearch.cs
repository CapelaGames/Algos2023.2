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
            
            Insert(5, root);
            Insert(5, root);
            Insert(8, root);
            Insert(3, root);
            Insert(1, root);
            Insert(9, root);
            Insert(4, root);
            Insert(2, root);

            PrintInOrder(root);
            
            Debug.Log(Search(7,root));
        }

        void Insert(int value, Node current)
        {
            if (value < current.data)
            {
                if (current.left == null)
                    current.left = new Node(value);
                else
                    Insert(value, current.left);
            }
            if (value > current.data)
            {
                if (current.right == null)
                    current.right = new Node(value);
                else
                    Insert(value, current.right);
            }
        }
        
        
        Node Search(int value, Node current)
        {
            if (value == current.data)
            {
                return current;
            }
            if (value < current.data)
            {
                if (current.left == null)
                    return null;
                else
                    return Search(value, current.left);
            }
            if (value > current.data)
            {
                if (current.right == null)
                    return null;
                else
                    return Search(value, current.right);
            }

            return null;
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
