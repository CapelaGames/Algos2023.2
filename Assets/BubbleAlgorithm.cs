using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class BubbleAlgorithm : MonoBehaviour
{
    public int[] bubbleAlgorithm;
    public bool sorted = false;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.W))
        {
            Sort();
        }
    }

    private int[] Sort()
    {
        while (!sorted)
        {
            sorted = true;

            for (int i = 0; i < bubbleAlgorithm.Length - 1; i++)
            {
                if (bubbleAlgorithm[i] > bubbleAlgorithm[i + 1])
                {
                    sorted = false;
                    int temp = bubbleAlgorithm[i + 1];
                    bubbleAlgorithm[i + 1] = bubbleAlgorithm[i];
                    bubbleAlgorithm[i] = temp;
                }
            }
        }
        return bubbleAlgorithm;
    }
}