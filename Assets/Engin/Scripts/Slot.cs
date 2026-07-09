using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

public class Slot: MonoBehaviour, IPointerClickHandler
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
        if(transform.parent!=null)
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

            InventoryManager.Instance.selectStackSize.SetActive(true);
            InventoryManager.Instance.selectStackSize.transform.position =
                InventoryManager.Instance.canvas.transform.TransformPoint(position);

            InventoryManager.Instance.SetStackInfo(items.Count);
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
    
}


