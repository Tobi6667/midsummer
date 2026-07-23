using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;
using UnityEngine.EventSystems;
using System;
using UnityEngine.InputSystem;

public class Inventory : MonoBehaviour
{
    private RectTransform inventoryRect;
    private float inventoryWidth, inventoryHeight;
    public int slots;
    public float slotPaddingLeft, slotPaddingTop;
    public int rows;
    private float hoverOffset;
    public float slotSize;

    [SerializeField] private PlayerInputController InputController_Drop;


    private List<GameObject> allSlots;

    int emptySlots;

    public CanvasGroup canvasGroup;

    static GameObject playerRef;

    private bool fadingIn;
    private bool fadingOut;
    public float fadeTime;

    public int EmptySlots
    {
        get { return emptySlots; }
        set { emptySlots = value; }
    }

    private bool isOpen;

    public bool IsOpen
    {
        get { return isOpen; }
        set { isOpen = value; }
    }

    public static bool mouseInside = false;

    void Start()
    {
        playerRef = GameObject.Find("Playernew");
       // InputController_Drop.OnItem1Clicked += On1Clicked;
        CreateLayout();
        InventoryManager.Instance.MovingSlot = GameObject.Find("MovingSlot").GetComponent<Slot>();
    }

    private void On1Clicked()
    {

        if (!mouseInside && InventoryManager.Instance.From != null)
        {
            //    InventoryManager.Instance.From.GetComponent<Image>().color = Color.white;

            //    foreach (ItemScript item in InventoryManager.Instance.From.Items)
            //    {
            //        if (item.spriteHighlighted.name == "Items00_4")
            //        {
            //            float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
            //            Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
            //            v *= 25;

            //            GameObject tmpDrop = Instantiate(
            //                InventoryManager.Instance.trapItem,
            //                playerRef.transform.position - v,
            //                Quaternion.identity
            //            ) as GameObject;

            //            tmpDrop.GetComponent<ItemScript>().Item = item.Item;
            //        }
            //        else if (item.spriteHighlighted.name == "Items00_11")
            //        {
            //            float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
            //            Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
            //            v *= 25;

            //            GameObject tmpDrop = Instantiate(
            //                InventoryManager.Instance.dropItem,
            //                playerRef.transform.position - v,
            //                Quaternion.identity
            //            ) as GameObject;

            //            tmpDrop.GetComponent<ItemScript>().Item = item.Item;
            //        }
            //    }

            //    InventoryManager.Instance.From.ClearSlot();
            //    Destroy(GameObject.Find("Hover"));

            //    InventoryManager.Instance.To = null;
            //    InventoryManager.Instance.From = null;
        }
        else if (!InventoryManager.Instance.MovingSlot.IsEmpty)
        {
            foreach (ItemScript item in InventoryManager.Instance.MovingSlot.Items)
            {
                if (item.tag == "Item")
                {
                    float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
                    Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
                    v *= 25;

                    GameObject tmpDrop = Instantiate(
                        InventoryManager.Instance.dropItem,
                        playerRef.transform.position - v,
                        Quaternion.identity
                    ) as GameObject;

                    tmpDrop.GetComponent<ItemScript>().Item = item.Item;
                }
                else if (item.tag == "Trap")
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
            }

            InventoryManager.Instance.MovingSlot.ClearSlot();
            Destroy(GameObject.Find("Hover"));
        }


        if (InventoryManager.Instance.HoverObject != null && Mouse.current != null)
        {
            Vector2 position;
            Vector2 mousePosition = Mouse.current.position.ReadValue();

            RectTransformUtility.ScreenPointToLocalPointInRectangle(
                InventoryManager.Instance.canvas.transform as RectTransform,
                mousePosition,
                InventoryManager.Instance.canvas.worldCamera,
                out position
            );

            position.Set(position.x, position.y - hoverOffset);

            InventoryManager.Instance.HoverObject.transform.position =
                InventoryManager.Instance.canvas.transform.TransformPoint(position);
        }
    }



    //void Update()
    //{
    //    if (Mouse.current != null && Mouse.current.leftButton.wasReleasedThisFrame)
    //    {
    //        if (!mouseInside && InventoryManager.Instance.From != null)
    //        {
    //        //    InventoryManager.Instance.From.GetComponent<Image>().color = Color.white;

    //        //    foreach (ItemScript item in InventoryManager.Instance.From.Items)
    //        //    {
    //        //        if (item.spriteHighlighted.name == "Items00_4")
    //        //        {
    //        //            float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
    //        //            Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
    //        //            v *= 25;

    //        //            GameObject tmpDrop = Instantiate(
    //        //                InventoryManager.Instance.trapItem,
    //        //                playerRef.transform.position - v,
    //        //                Quaternion.identity
    //        //            ) as GameObject;

    //        //            tmpDrop.GetComponent<ItemScript>().Item = item.Item;
    //        //        }
    //        //        else if (item.spriteHighlighted.name == "Items00_11")
    //        //        {
    //        //            float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
    //        //            Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
    //        //            v *= 25;

    //        //            GameObject tmpDrop = Instantiate(
    //        //                InventoryManager.Instance.dropItem,
    //        //                playerRef.transform.position - v,
    //        //                Quaternion.identity
    //        //            ) as GameObject;

    //        //            tmpDrop.GetComponent<ItemScript>().Item = item.Item;
    //        //        }
    //        //    }

    //        //    InventoryManager.Instance.From.ClearSlot();
    //        //    Destroy(GameObject.Find("Hover"));

    //        //    InventoryManager.Instance.To = null;
    //        //    InventoryManager.Instance.From = null;
    //        }
    //        else if (!InventoryManager.Instance.eventSystem.IsPointerOverGameObject()
    //                 && !InventoryManager.Instance.MovingSlot.IsEmpty)
    //        {
    //            foreach (ItemScript item in InventoryManager.Instance.MovingSlot.Items)
    //            {
    //                if (item.tag == "Item")
    //                {
    //                    float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
    //                    Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
    //                    v *= 25;

    //                    GameObject tmpDrop = Instantiate(
    //                        InventoryManager.Instance.dropItem,
    //                        playerRef.transform.position - v,
    //                        Quaternion.identity
    //                    ) as GameObject;

    //                    tmpDrop.GetComponent<ItemScript>().Item = item.Item;
    //                }
    //                else if (item.tag == "Trap")
    //                {
    //                    float angle = UnityEngine.Random.Range(0.00f, Mathf.PI * 2);
    //                    Vector3 v = new Vector3(Mathf.Sin(angle), 0, Mathf.Cos(angle));
    //                    v *= 25;

    //                    GameObject tmpDrop = Instantiate(
    //                        InventoryManager.Instance.trapItem,
    //                        playerRef.transform.position - v,
    //                        Quaternion.identity
    //                    ) as GameObject;

    //                    tmpDrop.GetComponent<ItemScript>().Item = item.Item;
    //                }
    //            }

    //            InventoryManager.Instance.MovingSlot.ClearSlot();
    //            Destroy(GameObject.Find("Hover"));
    //        }
    //    }

    //    if (InventoryManager.Instance.HoverObject != null && Mouse.current != null)
    //    {
    //        Vector2 position;
    //        Vector2 mousePosition = Mouse.current.position.ReadValue();

    //        RectTransformUtility.ScreenPointToLocalPointInRectangle(
    //            InventoryManager.Instance.canvas.transform as RectTransform,
    //            mousePosition,
    //            InventoryManager.Instance.canvas.worldCamera,
    //            out position
    //        );

    //        position.Set(position.x, position.y - hoverOffset);

    //        InventoryManager.Instance.HoverObject.transform.position =
    //            InventoryManager.Instance.canvas.transform.TransformPoint(position);
    //    }
    //}

    public virtual void SaveInventory()
    {
        string content = string.Empty;

        for (int i = 0; i < allSlots.Count; i++)
        {
            Slot tmp = allSlots[i].GetComponent<Slot>();

            if (!tmp.IsEmpty)
            {
                content += i + "-" + tmp.CurrentItem.Item.ItemName.ToString() + "-" + tmp.Items.Count.ToString() + ";";
            }
        }

        PlayerPrefs.SetString(gameObject.name + "content", content);
        PlayerPrefs.SetInt(gameObject.name + "slots", slots);
        PlayerPrefs.SetInt(gameObject.name + "rows", rows);
        PlayerPrefs.SetFloat(gameObject.name + "slotPaddingLeft", slotPaddingLeft);
        PlayerPrefs.SetFloat(gameObject.name + "slotPaddingTop", slotPaddingTop);
        PlayerPrefs.SetFloat(gameObject.name + "slotSize", slotSize);
        PlayerPrefs.SetFloat(gameObject.name + "xpos", inventoryRect.position.x);
        PlayerPrefs.SetFloat(gameObject.name + "ypos", inventoryRect.position.y);
        PlayerPrefs.Save();
    }

    //public virtual void ShowToolTip(GameObject slot)
    //{
    //    Slot tmpSlot = slot.GetComponent<Slot>();

    //    if (slot.GetComponentInParent<Inventory>().isOpen
    //        && !tmpSlot.IsEmpty
    //        && InventoryManager.Instance.HoverObject == null
    //        && !InventoryManager.Instance.selectStackSize.activeSelf)
    //    {
    //        InventoryManager.Instance.visualTextObject.text = tmpSlot.CurrentItem.GetTooltip();
    //        InventoryManager.Instance.sizeTextObject.text = InventoryManager.Instance.visualTextObject.text;
    //        InventoryManager.Instance.toolObject.SetActive(true);

    //        float xpos = slot.transform.position.x + slotPaddingLeft;
    //        float ypos = slot.transform.position.y - slot.GetComponent<RectTransform>().sizeDelta.y - slotPaddingTop;

    //        InventoryManager.Instance.toolObject.transform.position = new Vector2(xpos, ypos);
    //    }
    //}

    //public void HideToolTip()
    //{
    //    InventoryManager.Instance.toolObject.SetActive(false);
    //}

    public virtual void LoadInventory()
    {
        string content = PlayerPrefs.GetString(gameObject.name + "content");

        if (content != string.Empty)
        {
            slots = PlayerPrefs.GetInt(gameObject.name + "slots");
            rows = PlayerPrefs.GetInt(gameObject.name + "rows");
            slotPaddingLeft = PlayerPrefs.GetFloat(gameObject.name + "slotPaddingLeft");
            slotPaddingTop = PlayerPrefs.GetFloat(gameObject.name + "slotPaddingTop");
            slotSize = PlayerPrefs.GetFloat(gameObject.name + "slotSize");

            inventoryRect.position = new Vector3(
                PlayerPrefs.GetFloat(gameObject.name + "xpos"),
                PlayerPrefs.GetFloat(gameObject.name + "ypos"),
                inventoryRect.position.z
            );

            CreateLayout();

            string[] splitContent = content.Split(';');

            for (int x = 0; x < splitContent.Length - 1; x++)
            {
                string[] splitValues = splitContent[x].Split('-');

                int index = Int32.Parse(splitValues[0]);
                string itemName = splitValues[1];
                int amount = Int32.Parse(splitValues[2]);

                Item tmp = null;

                for (int i = 0; i < amount; i++)
                {
                    GameObject loadedItem = Instantiate(InventoryManager.Instance.itemObject);

                    if (tmp == null)
                    {
                        tmp = InventoryManager.Instance.ItemContainer.Consumables.Find(item => item.ItemName == itemName);
                    }

                    if (tmp == null)
                    {
                        tmp = InventoryManager.Instance.ItemContainer.Equipment.Find(item => item.ItemName == itemName);
                    }

                    if (tmp == null)
                    {
                        tmp = InventoryManager.Instance.ItemContainer.Weapons.Find(item => item.ItemName == itemName);
                    }

                    loadedItem.AddComponent<ItemScript>();
                    loadedItem.GetComponent<ItemScript>().Item = tmp;

                    allSlots[index].GetComponent<Slot>().AddItem(loadedItem.GetComponent<ItemScript>());

                    ItemScript loadedItemScript = loadedItem.GetComponent<ItemScript>();
                    loadedItemScript.Item = tmp;

                    allSlots[index].GetComponent<Slot>().AddItem(loadedItemScript);

                    // Keep the object alive, but hide it.
                    loadedItem.transform.SetParent(transform);
                    loadedItem.SetActive(false);
                }
            }
        }
    }

    public virtual void CreateLayout()
    {
        if (allSlots != null)
        {
            foreach (GameObject go in allSlots)
            {
                Destroy(go);
            }
        }

        allSlots = new List<GameObject>();
        emptySlots = slots;
        hoverOffset = slotSize * 0.01f;

        inventoryWidth = (slots / rows) * (slotSize + slotPaddingLeft) + slotPaddingLeft;
        inventoryHeight = rows * (slotSize + slotPaddingTop) + slotPaddingTop;

        inventoryRect = GetComponent<RectTransform>();

        inventoryRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, inventoryWidth);
        inventoryRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, inventoryHeight);

        int columns = slots / rows;

        for (int y = 0; y < rows; y++)
        {
            for (int x = 0; x < columns; x++)
            {
                GameObject newSlot = Instantiate(InventoryManager.Instance.slotPrefab);
                RectTransform slotRect = newSlot.GetComponent<RectTransform>();

                newSlot.name = "Slot";
                newSlot.transform.SetParent(this.transform.parent);

                slotRect.localPosition = inventoryRect.localPosition + new Vector3(
                    slotPaddingLeft * (x + 1) + slotSize * x,
                    -slotPaddingTop * (y + 1) - slotSize * y
                );

                slotRect.SetSizeWithCurrentAnchors(
                    RectTransform.Axis.Horizontal,
                    slotSize * InventoryManager.Instance.canvas.scaleFactor
                );

                slotRect.SetSizeWithCurrentAnchors(
                    RectTransform.Axis.Vertical,
                    slotSize * InventoryManager.Instance.canvas.scaleFactor
                );

                newSlot.transform.SetParent(this.transform);
                allSlots.Add(newSlot);
            }
        }
    }

    public bool AddItem(ItemScript item)
    {
        if (emptySlots > 0)
        {
            return PlaceEmpty(item);
        }

        return false;
    }

    void MoveInventory()
    {
        if (Mouse.current == null)
            return;

        Vector2 screenPos = Mouse.current.position.ReadValue();

        screenPos.x -= inventoryRect.sizeDelta.x * 0.5f * InventoryManager.Instance.canvas.scaleFactor;
        screenPos.y += inventoryRect.sizeDelta.y * 0.5f * InventoryManager.Instance.canvas.scaleFactor;

        Vector2 mousePos;

        RectTransformUtility.ScreenPointToLocalPointInRectangle(
            InventoryManager.Instance.canvas.transform as RectTransform,
            screenPos,
            InventoryManager.Instance.canvas.worldCamera,
            out mousePos
        );

        transform.position = InventoryManager.Instance.canvas.transform.TransformPoint(mousePos);
    }

    private bool PlaceEmpty(ItemScript item)
    {
        if (emptySlots > 0)
        {
            foreach (GameObject slot in allSlots)
            {
                Slot tmp = slot.GetComponent<Slot>();

                if (tmp.IsEmpty)
                {
                    tmp.AddItem(item);
                    return true;
                }
            }
        }

        return false;
    }

    public void MoveItem(GameObject clicked)
    {
        CanvasGroup cg = clicked.transform.parent.GetComponent<CanvasGroup>();

        bool shiftPressed = Keyboard.current != null && Keyboard.current.leftShiftKey.isPressed;

        if (cg != null && cg.alpha > 0 || clicked.transform.parent.parent.GetComponent<CanvasGroup>().alpha > 0)
        {
            InventoryManager.Instance.Clicked = clicked;

            if (!InventoryManager.Instance.MovingSlot.IsEmpty)
            {
                Slot tmp = clicked.GetComponent<Slot>();

                if (tmp.IsEmpty)
                {
                    tmp.AddItems(InventoryManager.Instance.MovingSlot.Items);
                    InventoryManager.Instance.MovingSlot.Items.Clear();
                    Destroy(GameObject.Find("Hover"));
                }
                else if (!tmp.IsEmpty
                         && InventoryManager.Instance.MovingSlot.CurrentItem.Item.ItemName == tmp.CurrentItem.Item.ItemName
                         && tmp.IsAvailable)
                {
                    MergeStacks(InventoryManager.Instance.MovingSlot, tmp);
                }
            }
            else if (InventoryManager.Instance.From == null
                     && clicked.transform.parent.GetComponent<Inventory>().isOpen
                     && !shiftPressed)
            {
                if (!clicked.GetComponent<Slot>().IsEmpty && !GameObject.Find("Hover"))
                {
                    InventoryManager.Instance.From = clicked.GetComponent<Slot>();
                    InventoryManager.Instance.From.GetComponent<Image>().color = Color.gray;
                    CreateHoverIcon();
                }
            }
            else if (InventoryManager.Instance.To == null && !shiftPressed)
            {
                InventoryManager.Instance.To = clicked.GetComponent<Slot>();
                Destroy(GameObject.Find("Hover"));
            }

            if (InventoryManager.Instance.To != null && InventoryManager.Instance.From != null)
            {
                if (!InventoryManager.Instance.To.IsEmpty
                    && InventoryManager.Instance.From.CurrentItem.Item.ItemName == InventoryManager.Instance.To.CurrentItem.Item.ItemName
                    && InventoryManager.Instance.To.IsAvailable)
                {
                    MergeStacks(InventoryManager.Instance.From, InventoryManager.Instance.To);
                }
                else
                {
                    Slot.SwapItems(InventoryManager.Instance.From, InventoryManager.Instance.To);
                }

                InventoryManager.Instance.From.GetComponent<Image>().color = Color.white;
                InventoryManager.Instance.To = null;
                InventoryManager.Instance.From = null;

                Destroy(GameObject.Find("Hover"));
            }
        }
    }

    private void CreateHoverIcon()
    {
        InventoryManager.Instance.HoverObject = Instantiate(InventoryManager.Instance.iconPrefab);

        InventoryManager.Instance.HoverObject.GetComponent<Image>().sprite =
            InventoryManager.Instance.Clicked.GetComponent<Image>().sprite;

        InventoryManager.Instance.HoverObject.name = "Hover";

        RectTransform hoverTransform = InventoryManager.Instance.HoverObject.GetComponent<RectTransform>();
        RectTransform clickedTransform = InventoryManager.Instance.Clicked.GetComponent<RectTransform>();

        hoverTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, clickedTransform.sizeDelta.x);
        hoverTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, clickedTransform.sizeDelta.y);

        InventoryManager.Instance.HoverObject.transform.SetParent(GameObject.Find("Canvas").transform, true);

        InventoryManager.Instance.HoverObject.transform.localScale =
            InventoryManager.Instance.Clicked.gameObject.transform.localScale;

        InventoryManager.Instance.HoverObject.transform.GetChild(0).GetComponent<Text>().text =
            InventoryManager.Instance.MovingSlot.Items.Count > 1
                ? InventoryManager.Instance.MovingSlot.Items.Count.ToString()
                : string.Empty;
    }

    private IEnumerator FadeOut()
    {
        if (!fadingOut)
        {
            fadingOut = true;
            fadingIn = false;

            StopCoroutine("FadeIn");

            float startAlpha = canvasGroup.alpha;
            float rate = 0.1f / fadeTime;
            float progress = 0.0f;

            while (progress < 1.0)
            {
                canvasGroup.alpha = Mathf.Lerp(startAlpha, 0, progress);
                progress += rate * Time.deltaTime;
                yield return null;
            }

            canvasGroup.alpha = 0;
            fadingOut = false;
        }
    }

    private void PutItemBack()
    {
        if (InventoryManager.Instance.From != null)
        {
            Destroy(GameObject.Find("Hover"));
            InventoryManager.Instance.From.GetComponent<Image>().color = Color.white;
            InventoryManager.Instance.From = null;
        }
        else if (!InventoryManager.Instance.MovingSlot.IsEmpty)
        {
            Destroy(GameObject.Find("Hover"));

            foreach (ItemScript item in InventoryManager.Instance.MovingSlot.Items)
            {
                InventoryManager.Instance.Clicked.GetComponent<Slot>().AddItem(item);
            }

            InventoryManager.Instance.MovingSlot.ClearSlot();
        }

     //   InventoryManager.Instance.selectStackSize.SetActive(false);
    }

    public void SplitStack()
    {
      //  InventoryManager.Instance.selectStackSize.SetActive(false);

        if (InventoryManager.Instance.SplitAmount == InventoryManager.Instance.MaxStackCount)
        {
            MoveItem(InventoryManager.Instance.Clicked);
        }
        else if (InventoryManager.Instance.SplitAmount > 0)
        {
            InventoryManager.Instance.MovingSlot.Items =
                InventoryManager.Instance.Clicked.GetComponent<Slot>().RemoveItems(InventoryManager.Instance.SplitAmount);

            CreateHoverIcon();
        }
    }

    public void ChangeStackText(int i)
    {
        InventoryManager.Instance.SplitAmount += i;

        if (InventoryManager.Instance.SplitAmount < 0)
            InventoryManager.Instance.SplitAmount = 0;

        if (InventoryManager.Instance.SplitAmount > InventoryManager.Instance.MaxStackCount)
            InventoryManager.Instance.SplitAmount = InventoryManager.Instance.MaxStackCount;

       // InventoryManager.Instance.stackText.text = InventoryManager.Instance.SplitAmount.ToString();
    }

    public void MergeStacks(Slot source, Slot destination)
    {
        int max = destination.CurrentItem.Item.MaxSize - destination.Items.Count;
        int count = source.Items.Count < max ? source.Items.Count : max;

        for (int i = 0; i < count; i++)
        {
            destination.AddItem(source.RemoveItem());

            InventoryManager.Instance.HoverObject.transform.GetChild(0).GetComponent<Text>().text =
                InventoryManager.Instance.MovingSlot.Items.Count.ToString();
        }

        if (source.Items.Count == 0)
        {
            source.ClearSlot();
            Destroy(GameObject.Find("Hover"));
        }
    }

    private IEnumerator FadeIn()
    {
        if (!fadingIn)
        {
            fadingOut = false;
            fadingIn = true;

            StopCoroutine("FadeOut");

            float startAlpha = canvasGroup.alpha;
            float rate = 0.1f / fadeTime;
            float progress = 0.0f;

            while (progress < 1.0)
            {
                canvasGroup.alpha = Mathf.Lerp(startAlpha, 1, progress);
                progress += rate * Time.deltaTime;
                yield return null;
            }

            canvasGroup.alpha = 1;
            fadingIn = false;
        }
    }

    public void OnDrag()
    {
        MoveInventory();
    }

    public void PointExit()
    {
        Debug.Log("Pointer Exit");
        mouseInside = false;
    }

    public void PointEnter()
    {
        Debug.Log("Pointer Enter");
        mouseInside = true;
    }

    public void Open()
    {
        if (canvasGroup.alpha > 0)
        {
            StartCoroutine("FadeOut");
            PutItemBack();
            //HideToolTip();
            isOpen = false;
        }
        else
        {
            StartCoroutine("FadeIn");
            isOpen = true;
        }
    }
}

