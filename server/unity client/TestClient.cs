using UnityEngine;
using System.Collections;
using DG.Tweening;

public class TestClient : MonoBehaviour 
{
    private SC1 sc1;
	void Start () 
    {
        sc1 = new SC1();
        sc1.ConnectServer("localhost", 8765);
	}

    void Update()
    {
        Vector3 pos = Vector3.Lerp(transform.position, RandomPosition(), Time.deltaTime * 10);
        string msg = string.Format("{0:F2}, {1:F2}, {2:F2}", pos.x, pos.y, pos.z);
        sc1.SendMessage(System.Text.Encoding.UTF8.GetBytes(msg));

        if (sc1.messages.Count > 0)
        {
            lock (sc1.messages)
            {
                byte[] data = sc1.messages.Dequeue();
                string str = System.Text.Encoding.UTF8.GetString(data);
                string[] array = str.Split(new char[]{ ',' });
                if (array.Length == 3)
                {
                    transform.localPosition = new Vector3(float.Parse(array[0]), float.Parse(array[1]), float.Parse(array[2]));
                }
            }
        }
    }

    Vector3 RandomPosition()
    {
        Vector3 pos = new Vector3(Random.Range(-200f, 200f),Random.Range(-300f, 300f), 0);
        return pos;
    }
}
