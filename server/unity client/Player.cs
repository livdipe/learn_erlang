using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine.UI;

public class Player : MonoBehaviour 
{
    private float angle = 0;
    private float speed = (2 * Mathf.PI) / 5;
    private float x, y;
    public float radius = 200;
    public Vector3 center = new Vector3(0, 0, 0);
	private PlayerDataModel playerDataModel;
	private Image image;

	void Awake()
	{
		image = GetComponent<Image>();
	}

	Color[] colors = new Color[]{Color.white, Color.black};
	public void Init(PlayerDataModel dataModel)
	{
		radius = dataModel.id * 50.0f + 100;
		speed = (2 * Mathf.PI) / 2;
		if (dataModel.sc1 != null)
			image.color = Color.white;
		else
			image.color = Color.black;
		playerDataModel = dataModel;
//		InvokeRepeating("UpdateTransform", 2, 5);
	}

	Vector3 targetPos;
	public void SetTarget(Vector3 pos)
	{
		targetPos = pos;
	}

    void Update()
    {
		transform.localPosition = Vector3.Lerp(transform.localPosition, targetPos, Time.deltaTime * 10);
		if (playerDataModel == null || playerDataModel.sc1 == null)
		{
			return ;
		}

        UpdateTransform();
    }

    void UpdateTransform()
    {
        angle += speed * Time.deltaTime;
        x = Mathf.Cos(angle) * radius + center.x;
        y = Mathf.Sin(angle) * radius + center.y;
		string msg = string.Format("move,{0}, {1:F2}, {2:F2}, {3:F2}", playerDataModel.id, x, y, 0);
		SendMessage(System.Text.Encoding.UTF8.GetBytes(msg));
    }
	
	void SendMessage(byte[] msg)
	{
		playerDataModel.sc1.SendMessage(msg);
	}
	
	void OnDestroy()
	{
		if (playerDataModel.sc1 != null)
		{
			playerDataModel.sc1.Close();
		}
	}
}

    