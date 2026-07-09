using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ItemContainer  {
    List<Item> weapons = new List<Item>();
    List<Item> equipment = new List<Item>();
    List<Item> consumables = new List<Item>();

    public List<Item> Weapons
    {
        get
        {
            return weapons;
        }

        set
        {
            weapons = value;
        }
    }

    public List<Item> Equipment
    {
        get
        {
            return equipment;
        }

        set
        {
            equipment = value;
        }
    }

    public List<Item> Consumables
    {
        get
        {
            return consumables;
        }

        set
        {
            consumables = value;
        }
    }
    public ItemContainer()
    {

    }

    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
