using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using System.Linq;

public class Slot: MonoBehaviour, IPointerClickHandler, IBeginDragHandler, IDragHandler, IEndDragHandler
{		private Stack<ItemScript> items;
		public Stack<ItemScript> Items
		{get {return items;}
			set{items=value;}}
		public Text stackTxt;
		public Sprite slotEmpty;
		public Sprite slotHighlight;
		public bool IsEmpty{
			get{return items.Count==0;}
		}
    static GameObject playerRef;
    CanvasGroup canvasGroup;
    public ItemType canContain;
		public void AddItem(ItemScript item)
		{if(IsEmpty)
        {
            transform.parent.GetComponent<Inventory>().EmptySlots--;

        }
        items.Push(item);
			if(items.Count>1)
			{stackTxt.text=items.Count.ToString();
			}
			ChangeSprite(item.spriteNeutral, item.spriteHighlighted);
		}
		public void AddItems(Stack<ItemScript> items)
		{ this.items=new Stack<ItemScript>(items);
			stackTxt.text=items.Count>1? items.Count.ToString():string.Empty;
			ChangeSprite(CurrentItem.spriteNeutral, CurrentItem.spriteHighlighted);

		}

	public bool IsAvailable
	{get{ return CurrentItem.Item.MaxSize>items.Count;}}
	public ItemScript CurrentItem
	{
        get {return items.Peek();}
    }
	void Start(){
        playerRef = GameObject.Find("PlayerEko");
        if (transform.parent!=null)
        {
            canvasGroup = transform.parent.GetComponent<CanvasGroup>();
        }
		RectTransform slotRect=GetComponent<RectTransform>();
		RectTransform txtRect=stackTxt.GetComponent<RectTransform>();
		int txtScaleFactor=(int) (slotRect.sizeDelta.x*0.60);
		stackTxt.resizeTextMaxSize=txtScaleFactor;
		stackTxt.resizeTextMinSize=txtScaleFactor;
		txtRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, slotRect.sizeDelta.x);
		txtRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, slotRect.sizeDelta.y);
	}

    public void OnBeginDrag(PointerEventData eventData)
    {
        Debug.Log("Begin Drag");
        if (eventData.button != PointerEventData.InputButton.Left)
            return;

        if (IsEmpty)
            return;

        if (GameObject.Find("Hover"))
            return;

        InventoryManager.Instance.Clicked = gameObject;
        InventoryManager.Instance.From = this;

        GetComponent<Image>().color = Color.gray;

        CreateDragIcon();
    }
    //public void OnBeginDrag(PointerEventData eventData)
    //{
    //    if (eventData.button != PointerEventData.InputButton.Left)
    //        return;

    //    if (IsEmpty)
    //        return;

    //    InventoryManager.Instance.From = this;
    //    InventoryManager.Instance.Clicked = gameObject;

    //    CreateDragIcon();
    //}
    public void OnDrag(PointerEventData eventData)
    {
        if (InventoryManager.Instance.HoverObject == null)
            return;
        Debug.Log("Dragging");
        InventoryManager.Instance.HoverObject.transform.position =
            eventData.position;
    }

    public void OnEndDrag(PointerEventData eventData)

    {
        InventoryManager.Instance.From.GetComponent<Image>().color = Color.white;

        foreach (ItemScript item in InventoryManager.Instance.From.Items)
        {
            if (item.spriteHighlighted.name == "Items00_4")
            {
                float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
                Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
                v *= 25;

                GameObject tmpDrop = Instantiate(
                    InventoryManager.Instance.trapItem,
                    playerRef.transform.position - v,
                    Quaternion.identity
                ) as GameObject;

                tmpDrop.GetComponent<ItemScript>().Item = item.Item;
            }
            else if (item.spriteHighlighted.name == "Items00_11")
            {
                float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
                Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
                v *= 25;

                GameObject tmpDrop = Instantiate( InventoryManager.Instance.dropItem, playerRef.transform.position - v, Quaternion.identity ) as GameObject;

                tmpDrop.GetComponent<ItemScript>().Item = item.Item;
            }
        }

        InventoryManager.Instance.From.ClearSlot();
        Destroy(GameObject.Find("Hover"));

        InventoryManager.Instance.To = null;
        InventoryManager.Instance.From = null;
    }
   


  

   

    

  

    //private void CleanupDrag()
    //{
    //    Image slotImage = GetComponent<Image>();

    //    if (slotImage != null)
    //    {
    //        slotImage.color = Color.white;
    //    }

    //    if (InventoryManager.Instance != null)
    //    {
    //        if (InventoryManager.Instance.HoverObject != null)
    //        {
    //            Destroy(InventoryManager.Instance.HoverObject);
    //            InventoryManager.Instance.HoverObject = null;
    //        }

    //        InventoryManager.Instance.To = null;
    //        InventoryManager.Instance.From = null;
    //    }
    //}
    //    public void OnEndDrag(PointerEventData eventData)
    //    {    foreach (ItemScript item in InventoryManager.Instance.From.Items)
    //                {
    //                    if (item.spriteHighlighted.name == "Items00_4")
    //                    {
    //                        float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
    //    Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
    //    v *= 25;

    //                        GameObject tmpDrop = Instantiate(
    //                            InventoryManager.Instance.trapItem,
    //                            playerRef.transform.position - v,
    //                            Quaternion.identity
    //                        ) as GameObject;

    //    tmpDrop.GetComponent<ItemScript>().Item = item.Item;
    //                    }
    //                    else if (item.spriteHighlighted.name == "Items00_11")
    //{
    //    float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
    //    Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
    //    v *= 25;

    //    GameObject tmpDrop = Instantiate(
    //        InventoryManager.Instance.dropItem,
    //        playerRef.transform.position - v,
    //        Quaternion.identity
    //    ) as GameObject;

    //    tmpDrop.GetComponent<ItemScript>().Item = item.Item;
    //}
    //                }

    //                InventoryManager.Instance.From.ClearSlot();
    //Destroy(GameObject.Find("Hover"));

    //InventoryManager.Instance.To = null;
    //InventoryManager.Instance.From = null;
    //            }


    // {
    //if (InventoryManager.Instance.From == null)
    //    return;

    //GameObject objectUnderPointer = eventData.pointerCurrentRaycast.gameObject;
    //Slot destinationSlot = null;

    //if (objectUnderPointer != null)
    //{
    //    destinationSlot = objectUnderPointer.GetComponent<Slot>();

    //    if (destinationSlot == null)
    //    {
    //        destinationSlot = objectUnderPointer.GetComponentInParent<Slot>();
    //    }
    //}

    //if (destinationSlot != null && destinationSlot != this)
    //{
    //    Slot.SwapItems(this, destinationSlot);
    //}
    //else
    //{
    //    DropItemsIntoWorld();
    //}

    //GetComponent<Image>().color = Color.white;

    //InventoryManager.Instance.From = null;
    //InventoryManager.Instance.To = null;

    //if (InventoryManager.Instance.HoverObject != null)
    //{
    //    Destroy(InventoryManager.Instance.HoverObject);
    //    InventoryManager.Instance.HoverObject = null;
    //}
    // }



    private void ChangeSprite(Sprite neutral, Sprite highlight )
	{
		GetComponent<Image>().sprite=neutral;
		SpriteState st=new SpriteState();
		st.highlightedSprite=highlight;
		st.pressedSprite=neutral;
		GetComponent<Button>().spriteState=st;
	}
	private void UseItem()
	{   if(!IsEmpty)
		{   items.Peek().Use(this);
			stackTxt.text=items.Count>1? items.Count.ToString():string.Empty;
			if(IsEmpty)
			{ChangeSprite(slotEmpty, slotHighlight);
				transform.parent.GetComponentInParent<Inventory>().EmptySlots++;
               }

		}
	}
	public void ClearSlot()

		{//clears all items on slot
		items.Clear();
		ChangeSprite(slotEmpty, slotHighlight);
		stackTxt.text=string.Empty;
        if (transform.parent!=null)
        {
        transform.parent.GetComponent<Inventory>().EmptySlots++;
        }
        

		}
    public Stack<ItemScript> RemoveItems(int amount)
    {
        Stack<ItemScript> tmp = new Stack<ItemScript>();
        for (int i = 0; i < amount; i++)
        {
            tmp.Push(items.Pop());
        }
            stackTxt.text = items.Count > 1 ? items.Count.ToString() : string.Empty;
        return tmp;
    }
    public ItemScript RemoveItem()
    {
        ItemScript tmp;
        tmp = items.Pop();
        stackTxt.text = items.Count > 1 ? items.Count.ToString() : string.Empty;
        return tmp;
    }
    //Handles onpointer events
    public void OnPointerClick(PointerEventData eventData)
    {
        Debug.Log("Slot clicked");
        // Right click uses the item
        if (eventData.button == PointerEventData.InputButton.Right &&
            !GameObject.Find("Hover") &&
            canvasGroup.alpha > 0)
        {
            UseItem();
        }
        
        // Shift + Left Click splits the stack
        else if (eventData.button == PointerEventData.InputButton.Left &&
                 Keyboard.current != null &&
                 Keyboard.current.leftShiftKey.isPressed &&
                 !IsEmpty &&
                 !GameObject.Find("Hover"))
        {
            Vector2 mousePosition = Mouse.current.position.ReadValue();

            Vector2 position;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(
                InventoryManager.Instance.canvas.transform as RectTransform,
                mousePosition,
                InventoryManager.Instance.canvas.worldCamera,
                out position);

            //InventoryManager.Instance.selectStackSize.SetActive(true);
            //InventoryManager.Instance.selectStackSize.transform.position =
            //    InventoryManager.Instance.canvas.transform.TransformPoint(position);

            //InventoryManager.Instance.SetStackInfo(items.Count);
        }
    }
    void Awake()
    {
        items = new Stack<ItemScript>();

    }
    public static void SwapItems(Slot from, Slot to)
    { ItemType movingType = from.CurrentItem.Item.ItemType; 
        if (to != null && from != null)
        {
            bool calcStats = from.transform.parent == CharacterPanel.Instance.transform || to.transform.parent == CharacterPanel.Instance.transform;
            if (movingType==ItemType.TwoHanded && CharacterPanel.Instance.OffHandSlot.IsEmpty|| movingType==ItemType.MainHand)
            {
                movingType = ItemType.GenericWeapon;
            }
            if (to.canContain == ItemType.Generic || movingType == to.canContain)
            {
                if (movingType != ItemType.OffHand || (CharacterPanel.Instance.WeaponSlot.IsEmpty || CharacterPanel.Instance.WeaponSlot.CurrentItem.Item.ItemType != ItemType.TwoHanded))
                {


                    Stack<ItemScript> tmpTo = new Stack<ItemScript>(to.Items);//stores the items from the "to" slot, so that we can make a swap.
                    to.AddItems(from.Items); //stores the items in the "from" slot  in the to slot.
                    if (tmpTo.Count == 0)//if "to" slot is 0 then we dont need to move  anything to the "from" slot.
                    {
                        to.transform.parent.GetComponent<Inventory>().EmptySlots--;
                        from.ClearSlot();

                    }
                    else
                    {
                        from.AddItems(tmpTo);
                    }
                }
            }
            //if (calcStats)
            //{
            //    CharacterPanel.Instance.CalculateStats();
            //}
        }
     
    }
    private void CreateDragIcon()
    {
        GameObject hoverObject = Instantiate(
            InventoryManager.Instance.iconPrefab,
            InventoryManager.Instance.canvas.transform
        );

        hoverObject.name = "Hover";

        hoverObject.GetComponent<Image>().sprite =
            GetComponent<Image>().sprite;

        RectTransform hoverRect =
            hoverObject.GetComponent<RectTransform>();

        RectTransform slotRect =
            GetComponent<RectTransform>();

        hoverRect.sizeDelta = slotRect.sizeDelta;
        hoverRect.position = slotRect.position;
       
        CanvasGroup hoverCanvasGroup =
            hoverObject.GetComponent<CanvasGroup>();

        if (hoverCanvasGroup == null)
        {
            hoverCanvasGroup =
                hoverObject.AddComponent<CanvasGroup>();
        }

        // Important: the dragged icon must not block raycasts.
        hoverCanvasGroup.blocksRaycasts = false;
        hoverCanvasGroup.interactable = false;

        InventoryManager.Instance.HoverObject = hoverObject;
    }
 
private void DropItemsIntoWorld()
    {
        if (IsEmpty)
            return;

        GameObject player = GameObject.Find("PlayerEko");

        if (player == null)
        {
            Debug.LogError("Player GameObject could not be found.");
            return;
        }

        // Copy the stack so it can safely be modified afterward.
        ItemScript[] itemsToDrop = items.ToArray();

        foreach (ItemScript itemScript in itemsToDrop)
        {
            if (itemScript == null)
            {
                Debug.LogWarning(
                    "DROPITEMSA destroyed or missing ItemScript was found in the slot."
                );
                continue;
            }

            Item itemData = itemScript.Item;

            if (itemData == null)
            {
                Debug.LogWarning("ItemScript has no Item data.");
                continue;
            }

            float angle = UnityEngine.Random.Range(0f, Mathf.PI * 2f);

            Vector3 offset = new Vector3(
                Mathf.Sin(angle),
                0f,
                Mathf.Cos(angle)
            ) * 25f;

            GameObject prefabToDrop;

            if (itemData.ItemType == ItemType.Trap)
            {
                prefabToDrop = InventoryManager.Instance.trapItem;
            }
            else
            {
                prefabToDrop = InventoryManager.Instance.dropItem;
            }

            GameObject droppedObject = Instantiate(
                prefabToDrop,
                player.transform.position - offset,
                Quaternion.identity
            );

            ItemScript droppedItemScript =
                droppedObject.GetComponent<ItemScript>();

            if (droppedItemScript == null)
            {
                droppedItemScript =
                    droppedObject.AddComponent<ItemScript>();
            }

            droppedItemScript.Item = itemData;

            // The old hidden inventory object is no longer needed.
            Destroy(itemScript.gameObject);
        }

        items.Clear();
        ChangeSprite(slotEmpty, slotHighlight);
        stackTxt.text = string.Empty;

        Inventory inventory = GetComponentInParent<Inventory>();

        if (inventory != null)
        {
            inventory.EmptySlots++;
        }
    }
}


