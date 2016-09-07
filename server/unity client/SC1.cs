using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;

public class SC1
{
    private TcpClient client = null;
    private NetworkStream outStream = null;
    private MemoryStream memStream;
    private BinaryReader reader;

    private const int MAX_READ = 8192;
    private byte[] byteBuffer = new byte[MAX_READ];
    public Queue<byte[]> messages = new Queue<byte[]>();

    public SC1()
    {
        memStream = new MemoryStream();
        reader = new BinaryReader(memStream);
    }

    //连接服务器
    public void ConnectServer(string host, int port)
    {
        client = null;
        client = new TcpClient();
        client.SendTimeout = 1000;
        client.ReceiveTimeout = 1000;
        client.NoDelay = true;
        try
        {
			Debug.LogError("C#Connecting ..." + Time.time + " host : " + host);
            client.BeginConnect(host, port, new AsyncCallback(OnConnect), null);
        }
        catch(Exception e)
        {
            this.Close();
            Debug.LogError(e.Message);
        }
    }

    //连上服务器
    void OnConnect(IAsyncResult asr)
    {
        client.EndConnect(asr);
        outStream = client.GetStream();
        client.GetStream().BeginRead(byteBuffer, 0, MAX_READ, new AsyncCallback(OnRead), null);
    }

    //读取消息
    void OnRead(IAsyncResult asr)
    {
        int bytesRead = 0;
        try
        {
            lock(client.GetStream())
            {
                bytesRead = client.GetStream().EndRead(asr);
            }
            if (bytesRead < 1)
            {
                OnDisconnected("bytesRead < 1");
                return ;
            }
            OnReceive(byteBuffer, bytesRead);
            lock(client.GetStream())
            {
                Array.Clear(byteBuffer, 0, byteBuffer.Length);
                client.GetStream().BeginRead(byteBuffer, 0, MAX_READ, new AsyncCallback(OnRead), null);
            }
        }
        catch(Exception e)
        {
            OnDisconnected(e.Message);
        }
    }

    //接收到消息
    void OnReceive(byte[] bytes, int length)
    {
        memStream.Seek(0, SeekOrigin.End);
        memStream.Write(bytes, 0, length);
        memStream.Seek(0, SeekOrigin.Begin);
        while (RemainingBytes() > 2)
        {
            short messageLen = IPAddress.NetworkToHostOrder(reader.ReadInt16());
            if (RemainingBytes() >= messageLen)
            {
				byte[] data = reader.ReadBytes(messageLen); 
                lock (messages)
                {
                    messages.Enqueue(data);
                }
            }
            else
            {
                memStream.Position = memStream.Position - 2;
            }
        }
        byte[] leftover = reader.ReadBytes((int)RemainingBytes());
        memStream.SetLength(0);
        memStream.Write(leftover, 0, leftover.Length);
    }

    //流中剩余数据长度
    private long RemainingBytes()
    {
        return memStream.Length - memStream.Position;
    }

    //发送消息
    public void SendMessage(byte[] bodyBytes)
    {
        short len = (short)(bodyBytes.Length);
        byte[] lenBytes = ConverterTool.ToNetworkOrder(len);
        byte[] sendData = ConverterTool.CombineBytes(new List<byte[]> { lenBytes, bodyBytes});
        WriteMessage(sendData);
    }

    //写数据
    void WriteMessage(byte[] message)
    {
        if (client != null && client.Connected)
        {
            outStream.BeginWrite(message, 0, message.Length, new AsyncCallback(OnWrite), null);
        }
        else
        {
            Debug.LogError("client.connected----->>false");
        }
    }

	public bool IsConnected()
	{
		if(client.Connected)
			return true;
		return false;
	}

    //向连接写入数据流
    void OnWrite(IAsyncResult asr)
    {
        try
		{
            outStream.EndWrite(asr);
        }
        catch(Exception e)
        {
            Debug.LogError("OnWrite--->" + e.Message);
        }
    }

    //丢失连接
    void OnDisconnected(string ms)
    {
        this.Close();
    }

    //关闭连接
    public void Close()
    {
        if (client != null)
        {
            if (client.Connected)
            {
                client.Close();
            }
            client = null;
        }
        reader.Close();
        memStream.Close();
    }
}
