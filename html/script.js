const inventoryGrid = document.getElementById("inventory-grid");
const closeBtn = document.getElementById("closeBtn");

// 🔹 Cerrar inventario
closeBtn.addEventListener("click", function () {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({})
    });
});

// 🔹 Escuchar mensajes de Lua
window.addEventListener("message", function (event) {
    const data = event.data;

    console.log("NUI:", data); // DEBUG

    if (data.type === "open") {
        document.body.style.display = "block";

        inventoryGrid.innerHTML = "";

        if (!data.items) return;

        data.items.forEach((item, index) => {
            const slot = document.createElement("div");
            slot.classList.add("slot");

            slot.innerHTML = `
                <div class="item-name">${item.name}</div>
                <div class="item-amount">x${item.amount || 1}</div>
            `;

            slot.addEventListener("click", function() {
                fetch(`https://${GetParentResourceName()}/useItem`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({ item: item.name, index})
                });
            })

            inventoryGrid.appendChild(slot);
        });
    }

    if (data.type === "close") {
        document.body.style.display = "none";
    }

    
});