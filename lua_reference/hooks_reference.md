# Menu Mods Hooks

### ElementCreated(currURL, urls, tag, class, parentClass, parentNum, content, attributes)

Called when a custom HTML element has been created.

Arguments:

- string currURL: The URL the element is being created on.
- table urls: The table of URLs the element exists on.
- string tag: The type of HTML tag.
- string class: The class name.
- string parentClass: The class name of the parent element.
- number parentNum: The ranking of the search results for the parent.
- string content: The inner HTML content of the element.
- vararg attributes: The attributes of the element.
