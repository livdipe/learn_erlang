using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;

public class PlayerManager : MonoBehaviour 
{
	public static PlayerManager Instance;
	public GameObject prefab;
	List<SC1> connects = new List<SC1>();
	Dictionary<int, PlayerDataModel> players = new Dictionary<int, PlayerDataModel>();

	void Awake()
	{
		Instance = this;
	}

	void Start () 
    {
//		for (int i = 0; i < 200; i++)
		{
	        SC1 sc = new SC1();
	        sc.ConnectServer("localhost", 8765);
			connects.Add(sc);
		}
	}

    void Update()
    {
		for (int i = 0; i < connects.Count; i++)
		{
			ProcessMessage(connects[i]);
		}
    }

	void ProcessMessage(SC1 sc1)
    {
        if (sc1.messages.Count > 0)
        {
            lock (sc1.messages)
            {
                byte[] data = sc1.messages.Dequeue();
                string str = System.Text.Encoding.UTF8.GetString(data);
//				Debug.LogError(str);
                string[] array = str.Split(new char[]{ ',' });
				switch(array[0])
				{
				// local player
				case "createplayer":
					CreatePlayer(int.Parse(array[1]), sc1);
					break;
				// other player
				case "newplayer":
//					Debug.LogError("newplayer id = " + array[1]);
					CreatePlayer(int.Parse(array[1]), null);
					break;
				// move
				case "move":
					MovePlayer(int.Parse(array[1]), new Vector3(float.Parse(array[2]), float.Parse(array[3]), float.Parse(array[4])));
					break;
				}
            }
        }
    }


    Vector3 RandomPosition()
    {
        Vector3 pos = new Vector3(Random.Range(-200f, 200f),Random.Range(-300f, 300f), 0);
        return pos;
    }

	void CreatePlayer(int id, SC1 sc)
	{
		if (players.ContainsKey(id))
		{
			return ;
		}

		GameObject obj = Instantiate(prefab) as GameObject;
		obj.transform.SetParent(prefab.transform.parent);
		obj.transform.localScale = Vector3.one;
		obj.SetActive(true);

		PlayerDataModel playerDataModel = new PlayerDataModel(id, obj.transform, sc);
		playerDataModel.player = obj.GetComponent<Player>();
		playerDataModel.player.Init(playerDataModel);
		players.Add(id, playerDataModel);
	}

	void MovePlayer(int id, Vector3 pos)
	{
		PlayerDataModel playerDataModel;
		if (players.TryGetValue(id, out playerDataModel))
		{
//			playerDataModel.tr.localPosition = pos;
			playerDataModel.player.SetTarget(pos);
		}
	}
}

public class PlayerDataModel
{
	public int id;
	public Transform tr;
	public SC1 sc1;
	public Player player;

	public PlayerDataModel(int id, Transform tr)
	{
		this.id = id;
		this.tr = tr;
	}

	public PlayerDataModel(int id, Transform tr, SC1 sc1)
	{
		this.id = id;
		this.tr = tr;
		this.sc1 = sc1;
	}
}
