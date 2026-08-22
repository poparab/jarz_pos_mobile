# -*- coding: utf-8 -*-
"""Guide pages: the order board, courier money, trips, expenses, line manager.

See ``pages_core.py`` for the content conventions.
"""

KANBAN = {
    "key": "kanban",
    "icon": "&#128203;",
    "title": {"en": "The order board", "ar": "بورد الطلبات"},
    "hero": {"en": "The order board", "ar": "بورد الطلبات"},
    "sub": {"en": "Every order lives here from the moment it is placed until it is delivered. "
                  "You move it one column at a time, and the money is recorded when it goes out.",
            "ar": "كل طلب بيعيش هنا من أول ما يتعمل لحد ما يتسلّم. إنت بتحركه عمود عمود، والفلوس "
                  "بتتسجل وقت ما يخرج."},
    "roles": ["staff", "line"],
    "blocks": [
        ("toc", [
            {"anchor": "columns", "title": {"en": "The columns", "ar": "الأعمدة"}},
            {"anchor": "card", "title": {"en": "Reading a card", "ar": "قراءة الكارت"}},
            {"anchor": "finding", "title": {"en": "Finding an order", "ar": "تلاقي طلب"}},
            {"anchor": "moving", "title": {"en": "Moving an order", "ar": "تحريك طلب"}},
            {"anchor": "ofd", "title": {"en": "Sending it out", "ar": "إرساله للتوصيل"}},
            {"anchor": "menu", "title": {"en": "The card menu", "ar": "قائمة الكارت"}},
            {"anchor": "trouble", "title": {"en": "Blocked?", "ar": "متوقف؟"}},
        ], {"en": "On this page", "ar": "في الصفحة دي"}),

        ("h", {"en": "The columns", "ar": "الأعمدة"}, "columns"),
        ("flow", [
            {"en": "Received", "ar": "مستلم"},
            {"en": "In Progress", "ar": "قيد التنفيذ"},
            {"en": "Ready", "ar": "جاهز"},
            {"en": "Out for Delivery", "ar": "خارج للتوصيل"},
            {"en": "Delivered", "ar": "تم التسليم"},
        ]),
        ("p", {"en": "Two more columns exist but you never drag into them: <strong>Cancelled</strong> and "
                     "<strong>Returned</strong>. An order gets there through the card menu, not by dragging.",
               "ar": "فيه عمودين كمان بس عمرك ما بتسحب عليهم: <strong>ملغي</strong> و<strong>مرتجع "
                     "بالكامل</strong>. الطلب بيوصلهم من قائمة الكارت، مش بالسحب."}),

        ("h", {"en": "Reading a card", "ar": "قراءة الكارت"}, "card"),
        ("tbl",
         [{"en": "What you see", "ar": "اللي بتشوفه"}, {"en": "What it means", "ar": "معناه"}],
         [
             [{"en": "The order number", "ar": "رقم الطلب"},
              {"en": "For an online order this is the WooCommerce number the customer knows. Use that "
                     "number when you talk to them.",
               "ar": "لو الطلب أونلاين، ده رقم ووكومرس اللي العميل يعرفه. استخدم الرقم ده وإنت بتكلمه."}],
             [{"en": "The area", "ar": "المنطقة"},
              {"en": "The delivery area, printed on the card so you can group orders going the same way.",
               "ar": "منطقة التوصيل، مكتوبة على الكارت عشان تجمع الطلبات الرايحة نفس الناحية."}],
             [{"en": "<strong>Pinned</strong> / <strong>No map pin</strong>",
               "ar": "<strong>الموقع متحدد</strong> / <strong>مفيش موقع</strong>"},
              {"en": "Whether the address has real map coordinates. <em>\"No map pin yet - add the location "
                     "link before dispatch\"</em> means the courier will be guessing. Fix it before you send "
                     "the order out.",
               "ar": "هل العنوان عليه إحداثيات حقيقية ولا لأ. <em>\"لسه مفيش موقع على الخريطة — ضيف رابط "
                     "الموقع قبل الخروج للتوصيل\"</em> معناها إن المندوب هيخمّن. ظبّطها قبل ما تبعت الطلب."}],
             [{"en": "The note strip", "ar": "شريط الملاحظة"},
              {"en": "<strong>LATEST NOTE</strong> shows the last operational note on the order. Tap it to read "
                     "all of them. If a colleague left a warning, it is here.",
               "ar": "<strong>آخر ملاحظة</strong> بتوريك آخر ملاحظة تشغيلية على الطلب. دوس عليها تقرا الكل. "
                     "لو زميلك ساب تحذير، هتلاقيه هنا."}],
             [{"en": "<strong>Stop 3</strong> / <strong>2/5 delivered</strong>",
               "ar": "<strong>محطة ٣</strong> / <strong>٢/٥ اتسلّم</strong>"},
              {"en": "The courier's run: which stop this order is, and how far along the run is. "
                     "<strong>Delivery missed</strong> means the courier tried and did not deliver.",
               "ar": "خط سير المندوب: الطلب ده محطة رقم كام، والخط وصل لفين. و<strong>التسليم فات</strong> "
                     "معناها إن المندوب جرّب ومحصلش تسليم."}],
             [{"en": "<strong>Returned</strong> / <strong>Partially returned</strong>",
               "ar": "<strong>مرتجع بالكامل</strong> / <strong>مرتجع جزئي</strong>"},
              {"en": "Part or all of the order came back and was credited to the customer.",
               "ar": "جزء من الطلب أو كله رجع واتحسب للعميل."}],
             [{"en": "<strong>Custom shipping pending</strong>",
               "ar": "<strong>الشحن المخصص قيد الانتظار</strong>"},
              {"en": "Somebody asked for a different delivery charge and a manager has not answered yet. "
                     "The order cannot go out until they do.",
               "ar": "حد طلب رسوم توصيل مختلفة والمدير لسه مردش. الطلب مش هيقدر يخرج قبل ما يرد."}],
         ]),

        ("h", {"en": "Finding an order", "ar": "تلاقي طلب"}, "finding"),
        ("bul", [
            {"en": "<strong>Search</strong> takes an order number, a customer name or a phone number. Phone is "
                   "the fastest when a customer calls.",
             "ar": "<strong>البحث</strong> بياخد رقم الطلب أو اسم العميل أو رقم التليفون. التليفون أسرع حاجة "
                   "لما عميل يتصل."},
            {"en": "The filter chips sit across the top and stay visible: date "
                   "(<strong>Today</strong>, <strong>Last 7 days</strong>, ...), customer, status, amount, branch. "
                   "The bar shows how many filters are on and <strong>Clear All</strong> removes them.",
             "ar": "شرايط الفلتر فوق وبتفضل ظاهرة: التاريخ (<strong>النهاردة</strong>، <strong>آخر ٧ "
                   "أيام</strong>...)، العميل، الحالة، المبلغ، الفرع. والشريط بيقولك كام فلتر شغال "
                   "و<strong>مسح الكل</strong> بيشيلهم."},
            {"en": "<strong>Filter by Branches</strong> matters if you cover more than one branch - an order you "
                   "cannot find is usually filtered out, not missing.",
             "ar": "<strong>تصفية حسب الفروع</strong> مهمة لو بتغطي أكتر من فرع — الطلب اللي مش لاقيه غالبًا "
                   "متفلتر، مش ضايع."},
        ]),
        ("call", "info",
         {"en": "The board updates itself", "ar": "البورد بيحدّث نفسه"},
         {"en": "New orders and moves made by colleagues appear on their own. <strong>Refresh Orders</strong> is "
                "there for when you suspect the connection dropped.",
          "ar": "الطلبات الجديدة وتحركات زمايلك بتظهر لوحدها. و<strong>تحديث الطلبات</strong> موجود لو "
                "شاكك إن النت قطع."}),

        ("h", {"en": "Moving an order", "ar": "تحريك طلب"}, "moving"),
        ("p", {"en": "Drag the card to the next column, or use <strong>Move</strong> from the card. Three rules "
                     "the app enforces:",
               "ar": "اسحب الكارت للعمود اللي بعده، أو استخدم <strong>انقل</strong> من الكارت. تلات قواعد "
                     "التطبيق بيفرضها:"}),
        ("bul", [
            {"en": "<strong>Forward only.</strong> <em>\"Cannot move backward\"</em> - an order that reached Ready "
                   "does not go back to In Progress. If it was moved by mistake, leave a note and tell your "
                   "line manager.",
             "ar": "<strong>لقدام بس.</strong> <em>\"لا يمكن التراجع للخلف\"</em> — الطلب اللي وصل جاهز مبيرجعش "
                   "لقيد التنفيذ. ولو اتحرك بالغلط، سيب ملاحظة وقول لمدير الخط."},
            {"en": "<strong>One stage at a time.</strong> <em>\"Can only move one stage at a time\"</em> - you cannot "
                   "jump Received straight to Out for Delivery.",
             "ar": "<strong>مرحلة واحدة كل مرة.</strong> <em>\"يمكن التقدم مرحلة واحدة فقط\"</em> — مينفعش تنط "
                   "من مستلم لخارج للتوصيل."},
            {"en": "<strong>No dragging into Cancelled or Returned.</strong> The app says so plainly: use the card "
                   "menu and pick <strong>Cancel Order</strong> or <strong>Return Order</strong> - both need a reason, "
                   "and both are line-manager actions.",
             "ar": "<strong>مفيش سحب على ملغي أو مرتجع.</strong> التطبيق بيقولها صريح: افتح قائمة الكارت واختار "
                   "<strong>إلغاء الطلب</strong> أو <strong>مرتجع الطلب</strong> — الاتنين محتاجين سبب، والاتنين "
                   "من صلاحيات مدير الخط."},
        ]),

        ("h", {"en": "Sending it out for delivery", "ar": "إرسال الطلب للتوصيل"}, "ofd"),
        ("p", {"en": "Moving a card into <strong>Out for Delivery</strong> is the step where the money is decided. "
                     "The app asks two things.",
               "ar": "نقل الكارت لـ<strong>خارج للتوصيل</strong> هي الخطوة اللي بتتحدد فيها الفلوس. التطبيق "
                     "بيسألك حاجتين."}),
        ("steps", [
            {"title": {"en": "Courier & Mode", "ar": "المندوب والطريقة"},
             "body": {"en": "Pick the courier taking it. Not in the list? <strong>New Courier</strong> creates one "
                            "(first name, last name, phone, and whether they are an employee or a supplier).",
                      "ar": "اختار المندوب اللي هياخده. مش لاقيه؟ <strong>مندوب جديد</strong> بيعمل واحد "
                            "(الاسم الأول والأخير والتليفون، وهل هو موظف ولا مورّد)."}},
            {"title": {"en": "Pay Now (Cash) or Settle Later", "ar": "ادفع الآن (نقدي) أو تسوية لاحقاً"},
             "body": {"en": "<strong>Pay Now</strong> - the cash changes hands right now at the counter. "
                            "<strong>Settle Later</strong> - the courier settles with the branch when they come "
                            "back, and the amount stays on their balance until they do.",
                      "ar": "<strong>ادفع الآن</strong> — الفلوس بتتسلّم دلوقتي على الكاشير. "
                            "<strong>تسوية لاحقاً</strong> — المندوب هيسوّي مع الفرع لما يرجع، والمبلغ بيفضل "
                            "على حسابه لحد ما يسوّي."}},
            {"title": {"en": "Check the settlement figures", "ar": "راجع أرقام التسوية"},
             "body": {"en": "The confirmation shows <strong>Collect From Courier</strong> or <strong>Pay Courier</strong> "
                            "with the arithmetic spelled out - order amount, shipping, and the net. Read the "
                            "net before you confirm; it is the number that has to match the cash in your hand.",
                      "ar": "التأكيد بيوريك <strong>تحصيل من المندوب</strong> أو <strong>سداد للمندوب</strong> "
                            "والحساب مكتوب — قيمة الطلب والشحن والصافي. اقرا الصافي قبل ما تأكد؛ ده الرقم "
                            "اللي لازم يطابق الفلوس اللي في إيدك."}},
        ]),
        ("call", "warn",
         {"en": "\"Invoice is UNPAID\"", "ar": "\"الفاتورة غير مدفوعة\""},
         {"en": "The order has no payment recorded yet. Choose the option that records the courier collecting "
                "cash now, otherwise the order goes out with nothing booked against it and the money has no "
                "home when it comes back.",
          "ar": "الطلب لسه مفيهوش دفع مسجل. اختار الاختيار اللي بيسجّل إن المندوب حصّل كاش دلوقتي، وإلا "
                "الطلب هيخرج من غير أي قيد والفلوس ملهاش مكان لما ترجع."}),
        ("bul", [
            {"en": "<strong>Pickup orders never settle.</strong> <em>\"Pickup orders don't require settlement\"</em> "
                   "is normal - no courier, no money to move.",
             "ar": "<strong>طلبات الاستلام مالهاش تسوية.</strong> <em>\"طلبات الاستلام لا تحتاج تسوية\"</em> "
                   "دي طبيعية — مفيش مندوب ومفيش فلوس تتحرك."},
            {"en": "<strong>Online orders awaiting InstaPay</strong> show <em>\"Out for delivery - awaiting "
                   "InstaPay\"</em>. The customer pays online, the courier carries nothing, and only the "
                   "shipping fee is settled with them.",
             "ar": "<strong>الطلبات الأونلاين المستنية إنستاباي</strong> بيظهر عليها <em>\"خرج للتوصيل — في "
                   "انتظار إنستاباي\"</em>. العميل بيدفع أونلاين، المندوب مش شايل فلوس، واللي بيتسوّى معاه "
                   "هو مصاريف الشحن بس."},
            {"en": "<strong>If the order is part of a trip</strong>, the app refuses and tells you to send the whole "
                   "trip from the Trips screen instead.",
             "ar": "<strong>لو الطلب جزء من رحلة</strong>، التطبيق هيرفض وهيقولك تبعت الرحلة كلها من شاشة "
                   "الرحلات."},
        ]),
        ("call", "stop",
         {"en": "Three things that block dispatch", "ar": "تلات حاجات بيوقفوا الخروج"},
         {"en": "(1) <em>\"Please select a sub-territory before sending out for delivery\"</em> - set it on the "
                "order. (2) <em>\"Custom shipping request is pending manager approval\"</em> - a manager has to "
                "answer first. (3) <strong>Approve stock shortage for dispatch</strong> - the goods are short at "
                "the warehouse, and a reason has to be typed before the order can leave.",
          "ar": "(١) <em>\"يرجى اختيار منطقة فرعية قبل الإرسال للتوصيل\"</em> — حددها على الطلب. "
                "(٢) <em>\"طلب الشحن المخصص قيد اعتماد المدير\"</em> — لازم المدير يرد الأول. "
                "(٣) <strong>اعتماد عجز المخزون قبل الإرسال</strong> — البضاعة ناقصة في المخزن، ولازم تكتب "
                "سبب قبل ما الطلب يخرج."}),

        ("h", {"en": "The card menu", "ar": "قائمة الكارت"}, "menu"),
        ("p", {"en": "The <strong>&#8942;</strong> on each card. What appears depends on where the order is and "
                     "what you are allowed to do.",
               "ar": "علامة <strong>&#8942;</strong> اللي على كل كارت. اللي بيظهر بيعتمد على الطلب واقف فين "
                     "وإنت مسموحلك بإيه."}),
        ("tbl",
         [{"en": "Action", "ar": "الإجراء"}, {"en": "Use it when", "ar": "تستخدمه لما"},
          {"en": "Who", "ar": "مين"}],
         [
             [{"en": "Notes", "ar": "الملاحظات"},
              {"en": "Anything the next person needs to know - customer called, address unclear, "
                     "second attempt. This is the memory of the order.",
               "ar": "أي حاجة اللي بعديك محتاج يعرفها — العميل اتصل، العنوان مش واضح، محاولة تانية. "
                     "دي ذاكرة الطلب."},
              {"en": "Everyone", "ar": "الكل"}],
             [{"en": "Edit Customer Address", "ar": "تعديل عنوان العميل"},
              {"en": "The address or phone is wrong. Changing the address can change the delivery charge, "
                     "and the app tells you when it does.",
               "ar": "العنوان أو التليفون غلط. تغيير العنوان ممكن يغيّر رسوم التوصيل، والتطبيق هيقولك."},
              {"en": "Everyone", "ar": "الكل"}],
             [{"en": "Change Delivery Slot", "ar": "تغيير موعد التوصيل"},
              {"en": "The customer wants a different time.", "ar": "العميل عايز ميعاد تاني."},
              {"en": "Everyone", "ar": "الكل"}],
             [{"en": "Edit Invoice", "ar": "تعديل الفاتورة"},
              {"en": "Items or quantities are wrong. This opens the order back in the cart; review it and "
                     "submit the amendment.",
               "ar": "الأصناف أو الكميات غلط. ده بيفتح الطلب تاني في السلة؛ راجعه وابعت التعديل."},
              {"en": "Everyone", "ar": "الكل"}],
             [{"en": "Print", "ar": "طباعة"},
              {"en": "The receipt. If it says the printer is not connected, open Printers from the header first.",
               "ar": "الإيصال. لو قالك الطابعة مش متصلة، افتح الطابعات من فوق الأول."},
              {"en": "Everyone", "ar": "الكل"}],
             [{"en": "Transfer Order", "ar": "تحويل الطلب"},
              {"en": "The wrong branch got it. The order moves and goes back to Received.",
               "ar": "الطلب راح لفرع غلط. الطلب هينتقل ويرجع لحالة مستلم."},
              {"en": "Everyone", "ar": "الكل"}],
             [{"en": "Request Custom Shipping", "ar": "طلب شحن مخصص"},
              {"en": "This order genuinely needs a different delivery charge. Give an amount and a real "
                     "reason (at least 10 characters). It waits for a manager, and the order cannot go out "
                     "meanwhile.",
               "ar": "الطلب ده فعلًا محتاج رسوم توصيل مختلفة. اكتب المبلغ وسبب حقيقي (١٠ حروف على "
                     "الأقل). هيستنى المدير، والطلب مش هيقدر يخرج في الوقت ده."},
              {"en": "Everyone", "ar": "الكل"}],
             [{"en": "Change collection method", "ar": "تغيير طريقة التحصيل"},
              {"en": "The customer paid by a different method than the one on the order. Only appears "
                     "while the courier balance for that order is still open - once it is settled, the "
                     "moment has passed. An online method needs a reference number.",
               "ar": "العميل دفع بطريقة غير اللي على الطلب. وبتظهر بس طول ما رصيد المندوب على الطلب ده "
                     "لسه مفتوح — بعد ما يتسوّى الوقت يكون عدّى. والطريقة الأونلاين محتاجة رقم مرجع."},
              {"en": "Line manager", "ar": "مدير الخط"}],
             [{"en": "Set Delivery Income", "ar": "حدد دخل التوصيل"},
              {"en": "Overrides the delivery charge on this order; blank restores the area default. It "
                     "creates an amendment.",
               "ar": "بيغيّر رسوم التوصيل على الطلب ده؛ وسيبها فاضية بترجّع افتراضي المنطقة. وبيعمل تعديل "
                     "للطلب."},
              {"en": "Manager pricing", "ar": "تسعير المدير"}],
             [{"en": "Return Order", "ar": "مرتجع الطلب"},
              {"en": "Goods are coming back after dispatch.", "ar": "بضاعة راجعة بعد ما خرجت."},
              {"en": "Line manager", "ar": "مدير الخط"}],
             [{"en": "Cancel Order", "ar": "إلغاء الطلب"},
              {"en": "The order should not exist. Greyed out if a partial payment was taken.",
               "ar": "الطلب ده مالوش لزمة أصلًا. وبيبقى مقفول لو اتاخدت دفعة جزئية."},
              {"en": "Line manager", "ar": "مدير الخط"}],
         ]),

        ("h", {"en": "Blocked? Read the message", "ar": "متوقف؟ اقرا الرسالة"}, "trouble"),
        ("faq", [
            {"q": {"en": "\"This order was fully returned and can no longer be moved\"",
                   "ar": "\"الطلب ده اترجع بالكامل ومش هينفع يتحرك تاني\""},
             "a": {"en": "A fully returned order is finished. It stays in the Returned column and nothing "
                         "moves it. If goods are going out again, that is a new order.",
                   "ar": "الطلب اللي رجع بالكامل خلاص خلص. بيفضل في عمود المرتجع ومفيش حاجة بتحركه. "
                         "ولو البضاعة هتخرج تاني، ده طلب جديد."}},
            {"q": {"en": "\"Settlement failed: courier party missing\"",
                   "ar": "\"فشلت التسوية: طرف المندوب مفقود\""},
             "a": {"en": "The order has no courier attached. Assign one and try again.",
                   "ar": "الطلب مفيهوش مندوب. عيّن واحد وحاول تاني."}},
            {"q": {"en": "\"Preview expired. Please retry.\"", "ar": "\"انتهت صلاحية المعاينة. أعد المحاولة\""},
             "a": {"en": "The settlement figures were calculated a while ago and are no longer trusted. Start "
                         "the move again - this protects you from settling against a stale number.",
                   "ar": "أرقام التسوية اتحسبت من فترة وبقت مش موثوقة. ابدأ الحركة من الأول — ده بيحميك "
                         "إنك تسوّي على رقم قديم."}},
            {"q": {"en": "\"Address saved, but ... matches no territory\"",
                   "ar": "\"العنوان اتحفظ، بس ... مش مطابق لأي منطقة\""},
             "a": {"en": "The address saved but the delivery charge did not update, because the area name on "
                         "it is not a real territory. Reopen the address and pick a proper territory, or the "
                         "order will carry the wrong shipping.",
                   "ar": "العنوان اتحفظ بس رسوم التوصيل ماتحدّثتش، لأن اسم المنطقة اللي عليه مش منطقة "
                         "حقيقية. افتح العنوان تاني واختار منطقة صح، وإلا الطلب هيمشي بشحن غلط."}},
            {"q": {"en": "The printer will not print", "ar": "الطابعة مش بتطبع"},
             "a": {"en": "Open <strong>Printers</strong> from the board header and reconnect. The header also shows "
                         "the current state - <strong>Not Connected</strong>, <strong>Connecting...</strong>, BLE or Classic.",
                   "ar": "افتح <strong>الطابعات</strong> من فوق في البورد وأعد التوصيل. وفوق كمان بيبان "
                         "الحالة — <strong>غير متصل</strong>، <strong>جارٍ الاتصال</strong>، BLE أو كلاسيك."}},
        ]),
    ],
}


COURIER = {
    "key": "courier-balances",
    "icon": "&#9878;",
    "title": {"en": "Courier money", "ar": "حساب المندوب"},
    "hero": {"en": "Courier balances and settling", "ar": "أرصدة المناديب والتسوية"},
    "sub": {"en": "Who owes whom, and how to clear it. You settle couriers yourself - it is not a manager "
                  "job, and your shift will not close until it is done.",
            "ar": "مين عليه لمين، وإزاي تصفّيها. إنت اللي بتسوّي مع المناديب — دي مش شغل مدير، وورديتك "
                  "مش هتقفل قبل ما تخلصها."},
    "roles": ["staff", "line"],
    "blocks": [
        ("h", {"en": "Opening it", "ar": "فتحها"}, "open"),
        ("p", {"en": "Menu &rarr; <strong>Courier Balances</strong>, or from the board header menu. It opens as a "
                     "list of couriers with a <strong>Net</strong> figure each.",
               "ar": "المنيو &rarr; <strong>أرصدة المناديب</strong>، أو من قائمة البورد اللي فوق. بتفتح كليستة "
                     "مناديب وقدام كل واحد <strong>الصافي</strong> بتاعه."}),

        ("h", {"en": "Reading a balance", "ar": "قراءة الرصيد"}, "reading"),
        ("tbl",
         [{"en": "Label", "ar": "المكتوب"}, {"en": "Meaning", "ar": "المعنى"},
          {"en": "What you do", "ar": "تعمل إيه"}],
         [
             [{"en": "Collect From Courier", "ar": "تحصيل من المندوب"},
              {"en": "The courier is holding the branch's money - they collected more from customers than "
                     "their delivery fees come to.",
               "ar": "المندوب ماسك فلوس الفرع — حصّل من العملا أكتر من أجرة التوصيل بتاعته."},
              {"en": "Take the cash and settle.", "ar": "خد الكاش وسوّي."}],
             [{"en": "Pay Courier", "ar": "سداد للمندوب"},
              {"en": "The branch owes the courier - their delivery fees come to more than they collected.",
               "ar": "الفرع عليه فلوس للمندوب — أجرته أكتر من اللي حصّله."},
              {"en": "Pay them from the drawer and settle.", "ar": "ادفعله من الدرج وسوّي."}],
             [{"en": "Settled", "ar": "مُسوى"},
              {"en": "Nothing outstanding.", "ar": "مفيش حاجة معلقة."},
              {"en": "Nothing.", "ar": "ولا حاجة."}],
         ]),
        ("call", "info",
         {"en": "The net is order minus shipping", "ar": "الصافي = الطلب ناقص الشحن"},
         {"en": "The settlement screen writes it out: <em>Collect (Order - Shipping)</em>. The courier keeps "
                "their delivery fee and hands over the rest; when the fee is bigger than what they collected, "
                "the direction flips and the branch pays them.",
          "ar": "شاشة التسوية بتكتبها صريح: <em>تحصيل (الطلب - الشحن)</em>. المندوب بياخد أجرته وبيسلّم "
                "الباقي؛ ولما الأجرة تبقى أكبر من اللي حصّله، الاتجاه بينقلب والفرع هو اللي بيدفعله."}),

        ("h", {"en": "Settling", "ar": "التسوية"}, "settling"),
        ("steps", [
            {"title": {"en": "Open the courier", "ar": "افتح المندوب"},
             "body": {"en": "Tapping a courier shows <strong>Details</strong> - every order behind that balance, "
                            "with its city and amount. Check the list against what the courier is telling you.",
                      "ar": "لما تدوس على مندوب بتظهر <strong>التفاصيل</strong> — كل طلب ورا الرصيد ده، "
                            "ومعاه المدينة والمبلغ. طابق القايمة مع اللي المندوب بيقوله."}},
            {"title": {"en": "Preview before you settle", "ar": "عاين قبل ما تسوّي"},
             "body": {"en": "The preview button shows exactly what the settlement will post. Use it when the "
                            "number surprises you.",
                      "ar": "زرار المعاينة بيوريك بالظبط التسوية هتسجّل إيه. استخدمه لما الرقم يستغربك."}},
            {"title": {"en": "Count the money first", "ar": "عدّ الفلوس الأول"},
             "body": {"en": "Hand over or take the cash, and only then confirm. Settling in the app is the "
                            "record of a thing that already happened.",
                      "ar": "سلّم أو استلم الكاش، وبعدين أكّد. التسوية في التطبيق دي تسجيل لحاجة حصلت خلاص."}},
            {"title": {"en": "Settle, or Settle All", "ar": "سوّي، أو سوّي الكل"},
             "body": {"en": "<strong>Settle</strong> clears one order. <strong>Settle All</strong> clears every open "
                            "order for that courier at once and asks you to confirm the total first - use it "
                            "at end of shift when the courier is standing there.",
                      "ar": "<strong>تسوية</strong> بتصفّي طلب واحد. و<strong>تسوية الكل</strong> بتصفّي كل "
                            "الطلبات المفتوحة للمندوب ده مرة واحدة وبتأكدلك الإجمالي الأول — استخدمها آخر "
                            "الوردية والمندوب واقف قدامك."}},
        ]),
        ("call", "warn",
         {"en": "Do not settle twice", "ar": "متسوّيش مرتين"},
         {"en": "If the confirmation seems slow, wait - do not tap again. Two taps have double-paid orders "
                "before. If you are unsure whether it went through, reopen the balances and look.",
          "ar": "لو التأكيد قعد، استنى — متدوسش تاني. حصل قبل كده إن دوستين دفعوا الطلب مرتين. ولو مش "
                "متأكد إنها عدت، اقفل وافتح الأرصدة تاني وشوف."}),

        ("h", {"en": "Questions", "ar": "أسئلة"}, "trouble"),
        ("faq", [
            {"q": {"en": "\"No couriers found\"", "ar": "\"لا يوجد مندوبون\""},
             "a": {"en": "Nobody has an open balance on this branch - which is what you want at the end of a "
                         "shift. If you expected somebody, check you are on the right branch.",
                   "ar": "مفيش حد عليه رصيد مفتوح على الفرع ده — وده اللي إنت عايزه آخر الوردية. ولو كنت "
                         "متوقع حد، اتأكد إنك على الفرع الصح."}},
            {"q": {"en": "\"Nothing to pay or collect\"", "ar": "\"لا يوجد مبلغ للتحصيل أو السداد\""},
             "a": {"en": "The order's amount and the delivery fee cancel out. Settle it anyway to clear it "
                         "off the shift.",
                   "ar": "قيمة الطلب وأجرة التوصيل بيلغوا بعض. سوّيه برضه عشان يخرج من الوردية."}},
            {"q": {"en": "The courier disagrees with the total", "ar": "المندوب مش موافق على الإجمالي"},
             "a": {"en": "Open <strong>Details</strong> and go order by order. Nine times out of ten it is one order "
                         "that was marked Pay Now when the courier actually collected, or the other way "
                         "round - your line manager can correct the collection method.",
                   "ar": "افتح <strong>التفاصيل</strong> وامشي طلب طلب. غالبًا هتلاقي طلب اتحدد ادفع الآن "
                         "والمندوب هو اللي حصّل، أو العكس — مدير الخط يقدر يصحّح طريقة التحصيل."}},
        ]),
    ],
}


TRIPS = {
    "key": "trips",
    "icon": "&#128666;",
    "title": {"en": "Delivery trips", "ar": "رحلات التوصيل"},
    "hero": {"en": "Delivery trips", "ar": "رحلات التوصيل"},
    "sub": {"en": "When one courier takes several orders in one run, group them into a trip and move them "
                  "together instead of one card at a time.",
            "ar": "لما مندوب واحد ياخد كذا طلب في خرجة واحدة، اجمعهم في رحلة وحركهم مع بعض بدل ما "
                  "تحرك كارت كارت."},
    "roles": ["staff", "line"],
    "blocks": [
        ("h", {"en": "Creating a trip", "ar": "عمل رحلة"}, "create"),
        ("steps", [
            {"title": {"en": "Select the orders on the board", "ar": "اختار الطلبات من البورد"},
             "body": {"en": "Use <strong>Select Orders</strong> and tap the cards going out together. The header "
                            "counts them for you.",
                      "ar": "استخدم <strong>اختار طلبات</strong> ودوس على الكروت اللي هتخرج مع بعض. "
                            "والعداد فوق بيعدهملك."}},
            {"title": {"en": "One branch only", "ar": "فرع واحد بس"},
             "body": {"en": "<em>\"Select invoices from one branch only to create a trip\"</em> - a trip belongs to "
                            "one branch. Split the selection if you mixed them.",
                      "ar": "<em>\"اختار فواتير من فرع واحد بس عشان تعمل رحلة\"</em> — الرحلة بتبقى لفرع واحد. "
                            "لو خلطت، قسّم الاختيار."}},
            {"title": {"en": "Fix any missing sub-territory", "ar": "ظبّط المنطقة الفرعية الناقصة"},
             "body": {"en": "If an order has no sub-territory, the app names it and refuses until you set it. "
                            "It is what tells the courier which part of the area they are going to.",
                      "ar": "لو طلب مفيهوش منطقة فرعية، التطبيق هيسمّيه ومش هيكمّل قبل ما تحددها. دي اللي "
                            "بتقول للمندوب رايح أنهي جزء من المنطقة."}},
            {"title": {"en": "Review and create", "ar": "راجع واعمل الرحلة"},
             "body": {"en": "<strong>Create Delivery Trip</strong> shows the order count, the total amount, the total "
                            "shipping and the courier picker. Pick the courier and confirm.",
                      "ar": "<strong>إنشاء رحلة توصيل</strong> بتوريك عدد الطلبات وإجمالي المبلغ وإجمالي "
                            "الشحن واختيار المندوب. اختار المندوب وأكّد."}},
        ]),
        ("call", "warn",
         {"en": "Double Shipping", "ar": "شحن مضاعف"},
         {"en": "If the trip screen flags <strong>Double Shipping</strong>, two orders in the selection are each "
                "carrying a full delivery charge for the same run. Check it before you create the trip - it "
                "is easier to fix now than after the money moves.",
          "ar": "لو شاشة الرحلة نبّهت <strong>شحن مضاعف</strong>، يبقى فيه طلبين في الاختيار كل واحد شايل "
                "رسوم توصيل كاملة لنفس الخرجة. راجعها قبل ما تعمل الرحلة — تصليحها دلوقتي أسهل من بعد "
                "ما الفلوس تتحرك."}),

        ("h", {"en": "Running the trip", "ar": "تشغيل الرحلة"}, "running"),
        ("bul", [
            {"en": "<strong>Active</strong> holds trips that are out or about to go; <strong>Completed</strong> is history.",
             "ar": "<strong>نشطة</strong> فيها الرحلات اللي بره أو هتخرج؛ و<strong>مكتملة</strong> دي الأرشيف."},
            {"en": "<strong>Send for Delivery</strong> moves every order in the trip out at once. Do this from "
                   "here, not from the individual cards.",
             "ar": "<strong>إرسال للتوصيل</strong> بيطلّع كل طلبات الرحلة مرة واحدة. اعمل كده من هنا مش من "
                   "الكروت واحد واحد."},
            {"en": "<strong>Mark as Delivered</strong> closes the whole trip when the courier is back and "
                   "everything landed. If some orders did not land, do not mark the trip - handle those "
                   "orders on the board first.",
             "ar": "<strong>تعليم كمسلمة</strong> بيقفل الرحلة كلها لما المندوب يرجع وكل حاجة اتسلمت. ولو "
                   "فيه طلبات ماتسلمتش، متعلّمش الرحلة — اتصرف في الطلبات دي على البورد الأول."},
        ]),
        ("call", "info",
         {"en": "The money still runs per order", "ar": "الفلوس لسه بتمشي بالطلب"},
         {"en": "A trip groups the movement, not the cash. Each order still settles against the courier's "
                "balance in the normal way - see the Courier money page.",
          "ar": "الرحلة بتجمّع الحركة، مش الفلوس. كل طلب لسه بيتسوّى على حساب المندوب زي ما هو — "
                "شوف صفحة حساب المندوب."}),
    ],
}


EXPENSES = {
    "key": "expenses",
    "icon": "&#128179;",
    "title": {"en": "Expenses & item requests", "ar": "المصاريف وطلبات الأصناف"},
    "hero": {"en": "Expenses and item requests", "ar": "المصاريف وطلبات الأصناف"},
    "sub": {"en": "Two different things on purpose: money that already left the drawer, and stock you are "
                  "running out of.",
            "ar": "حاجتين مختلفين بقصد: فلوس خرجت من الدرج خلاص، وبضاعة قربت تخلص."},
    "roles": ["staff", "line"],
    "blocks": [
        ("h", {"en": "Recording an expense", "ar": "تسجيل مصروف"}, "expense"),
        ("p", {"en": "Menu &rarr; <strong>Expenses</strong> &rarr; <strong>New Expense</strong>. Record it the same day - "
                     "an expense remembered next week is an expense nobody can verify.",
               "ar": "المنيو &rarr; <strong>المصروفات</strong> &rarr; <strong>مصروف جديد</strong>. سجّله في نفس "
                     "اليوم — المصروف اللي بتفتكره الأسبوع الجاي محدش هيقدر يتأكد منه."}),
        ("tbl",
         [{"en": "Field", "ar": "الخانة"}, {"en": "What to put in it", "ar": "تحط فيها إيه"}],
         [
             [{"en": "Reason", "ar": "سبب الصرف"},
              {"en": "The expense account - the category the money went to. Pick the closest one; do not "
                     "force it into whatever is at the top.",
               "ar": "حساب المصروف — التصنيف اللي الفلوس راحت له. اختار أقرب واحد؛ متحطهاش في أول واحد "
                     "في القايمة وخلاص."}],
             [{"en": "Pay from", "ar": "الدفع من"},
              {"en": "Where the money actually came from - the branch drawer, or another payment source. "
                     "Getting this wrong makes your shift not balance.",
               "ar": "الفلوس خرجت منين فعلًا — درج الفرع، ولا مصدر دفع تاني. لو ظبطتها غلط، ورديتك "
                     "مش هتظبط."}],
             [{"en": "Amount", "ar": "القيمة"},
              {"en": "What was actually spent.", "ar": "اللي اتصرف بالظبط."}],
             [{"en": "Expense date", "ar": "تاريخ المصروف"},
              {"en": "The day the money left, not the day you are typing.",
               "ar": "اليوم اللي الفلوس خرجت فيه، مش اليوم اللي بتكتب فيه."}],
             [{"en": "Remarks", "ar": "ملاحظات"},
              {"en": "Optional, but this is where you say who, what and why. Write it.",
               "ar": "اختياري، بس دي المكان اللي بتقول فيه مين وإيه وليه. اكتبها."}],
         ]),
        ("call", "manager",
         {"en": "Approval is manager-tier", "ar": "الاعتماد للمدير الأعلى"},
         {"en": "Staff and line managers both see <strong>Submit for approval</strong>, and both get "
                "<em>\"Expense submitted for approval\"</em>. Only a JARZ Manager can approve - a line manager "
                "cannot approve their own or anyone else's.",
          "ar": "الموظف ومدير الخط الاتنين بيشوفوا <strong>إرسال للاعتماد</strong>، والاتنين بيجيلهم "
                "<em>\"تم إرسال المصروف لاعتماد المدير\"</em>. والاعتماد من JARZ Manager بس — مدير الخط "
                "مش بيعتمد لا بتاعه ولا بتاع حد."}),
        ("bul", [
            {"en": "The month view totals <strong>Approved</strong> and <strong>Pending</strong> separately, so you can "
                   "see what is still waiting.",
             "ar": "شاشة الشهر بتجمع <strong>المعتمدة</strong> و<strong>قيد الاعتماد</strong> كل واحدة لوحدها، "
                   "فتقدر تشوف اللي لسه مستني."},
            {"en": "<strong>Timeline</strong> on an expense shows who did what to it and when.",
             "ar": "<strong>الخط الزمني</strong> على المصروف بيوريك مين عمل إيه وإمتى."},
        ]),

        ("h", {"en": "Asking for stock", "ar": "طلب بضاعة"}, "requests"),
        ("p", {"en": "Menu &rarr; <strong>Item Requests</strong>. Anyone can raise one - deliberately, because the "
                     "person who notices the shortage is usually not the person who buys.",
               "ar": "المنيو &rarr; <strong>طلبات الأصناف</strong>. أي حد يقدر يطلب — وده بقصد، لأن اللي بيلاحظ "
                     "النقص مش غالبًا هو اللي بيشتري."}),
        ("steps", [
            {"title": {"en": "Tap +", "ar": "دوس +"},
             "body": {"en": "<strong>Request items</strong> - add the items you need with quantities.",
                      "ar": "<strong>اطلب أصناف</strong> — ضيف الأصناف اللي محتاجها بالكميات."}},
            {"title": {"en": "Say when you need it", "ar": "قول محتاجها إمتى"},
             "body": {"en": "<strong>Needed by</strong> is what turns a request into a priority. A request with a "
                            "real date gets bought; one without drifts.",
                      "ar": "<strong>محتاجها قبل</strong> هي اللي بتخلي الطلب أولوية. الطلب اللي عليه تاريخ "
                            "حقيقي بيتشرى؛ واللي من غير بيتنسى."}},
            {"title": {"en": "Add a note", "ar": "ضيف ملاحظة"},
             "body": {"en": "Brand, size, urgency - whatever the person buying would otherwise have to call "
                            "and ask you.",
                      "ar": "الماركة، المقاس، الاستعجال — أي حاجة اللي هيشتري كان هيتصل بيك يسألك عليها."}},
            {"title": {"en": "Send it", "ar": "ابعته"},
             "body": {"en": "Track it under <strong>Mine</strong>. It moves through <strong>Waiting</strong> &rarr; "
                            "<strong>Ordered</strong> &rarr; <strong>Partly bought</strong> &rarr; <strong>Bought</strong>, "
                            "and can come back <strong>Rejected</strong> with a reason.",
                      "ar": "تابعه من <strong>طلباتي</strong>. بيمشي من <strong>مستني</strong> &rarr; "
                            "<strong>اتطلب</strong> &rarr; <strong>اتشرى جزء</strong> &rarr; <strong>اتشرى</strong>، "
                            "وممكن يرجع <strong>مرفوض</strong> ومعاه السبب."}},
        ]),
        ("call", "info",
         {"en": "Not the same thing", "ar": "مش نفس الحاجة"},
         {"en": "An <strong>expense</strong> is money that already left. An <strong>item request</strong> is a thing you "
                "still need. Buying against a request is a manager job; asking is everyone's.",
          "ar": "<strong>المصروف</strong> فلوس خرجت خلاص. و<strong>طلب الصنف</strong> حاجة لسه محتاجها. الشرا "
                "على الطلب شغل مدير؛ والطلب شغل الكل."}),
    ],
}


LINE_MANAGER = {
    "key": "line-manager",
    "icon": "&#127894;",
    "title": {"en": "Line manager", "ar": "مدير الخط"},
    "hero": {"en": "What a line manager can do", "ar": "مدير الخط بيقدر يعمل إيه"},
    "sub": {"en": "A line manager is a floor supervisor: everything a staff member does, plus the calls that "
                  "need somebody accountable. Nothing here is available to staff.",
            "ar": "مدير الخط مشرف أرضي: بيعمل كل اللي الموظف بيعمله، وزيادة القرارات اللي محتاجة حد "
                  "مسؤول. مفيش حاجة هنا متاحة للموظف."},
    "roles": ["line"],
    "blocks": [
        ("call", "manager",
         {"en": "Read the staff pages first", "ar": "اقرا صفحات الموظفين الأول"},
         {"en": "Everything on the other pages applies to you unchanged. This page is only the extra.",
          "ar": "كل اللي في الصفحات التانية بينطبق عليك زي ما هو. الصفحة دي بس الزيادة."}),

        ("h", {"en": "Cancelling an order", "ar": "إلغاء طلب"}, "cancel"),
        ("steps", [
            {"title": {"en": "Card menu &rarr; Cancel Order", "ar": "قائمة الكارت &rarr; إلغاء الطلب"},
             "body": {"en": "Never by dragging. The dialog shows the invoice, the total and the outstanding "
                            "amount so you can see what you are reversing.",
                      "ar": "مش بالسحب أبدًا. الشاشة بتوريك الفاتورة والإجمالي والمتبقي عشان تشوف إنت "
                            "بترجّع إيه."}},
            {"title": {"en": "Give a reason", "ar": "اكتب السبب"},
             "body": {"en": "Pick one, or choose custom and describe it. This is the only record of why the "
                            "order disappeared.",
                      "ar": "اختار واحد، أو اختار سبب مخصص واكتبه. ده السجل الوحيد اللي بيقول الطلب "
                            "اختفى ليه."}},
            {"title": {"en": "Hand the money back first", "ar": "سلّم الفلوس الأول"},
             "body": {"en": "If the order was paid, the app says so: <em>\"The payment on this order will be "
                            "reversed. Hand the money back to the customer before confirming.\"</em> A credit note "
                            "is created and its number is shown.",
                      "ar": "لو الطلب كان مدفوع، التطبيق هيقولك: <em>\"الدفعة اللي على الطلب ده هتترجع. سلّم "
                            "الفلوس للعميل قبل ما تأكد.\"</em> وهيتعمل إشعار دائن وهيبان رقمه."}},
        ]),
        ("call", "stop",
         {"en": "Partial payments block a cancel", "ar": "الدفعة الجزئية بتوقف الإلغاء"},
         {"en": "The menu entry reads <strong>Cancel Order (settle payments first)</strong> and is greyed out. "
                "Settle or refund the partial payment, then cancel. Do not work around it.",
          "ar": "الاختيار بيبقى مكتوب عليه <strong>إلغاء الطلب (يجب تسوية المدفوعات أولًا)</strong> ومقفول. "
                "سوّي أو رجّع الدفعة الجزئية، وبعدين ألغِ. متلفّش حواليها."}),

        ("h", {"en": "Returning an order", "ar": "مرتجع طلب"}, "return"),
        ("p", {"en": "A return is for goods that already went out and came back. Cancel is for an order that "
                     "should not have existed. Do not use one for the other.",
               "ar": "المرتجع للبضاعة اللي خرجت ورجعت. والإلغاء للطلب اللي مكانش المفروض يتعمل أصلًا. "
                     "متستخدمش واحد مكان التاني."}),
        ("steps", [
            {"title": {"en": "Pick what is coming back", "ar": "اختار الراجع"},
             "body": {"en": "<strong>Items coming back</strong> lists each line with how much of it can still be "
                            "returned. Return the whole order or only some lines - the app tells you which "
                            "one you are doing and what the customer will be credited.",
                      "ar": "<strong>الأصناف الراجعة</strong> بتعرض كل سطر وكام منه لسه ينفع يرجع. رجّع الطلب "
                            "كله أو سطور معينة — والتطبيق بيقولك إنت بتعمل أنهي واحدة وهيتحسب للعميل كام."}},
            {"title": {"en": "Say why", "ar": "قول ليه"},
             "body": {"en": "<strong>Return type</strong>: customer return, failed delivery, damaged, or wrong item. "
                            "Plus a written reason. This is what the returns numbers get read from later.",
                      "ar": "<strong>نوع المرتجع</strong>: العميل رجّع، التوصيل فشل، تالف، أو صنف غلط. وكمان "
                            "سبب مكتوب. ده اللي أرقام المرتجعات بتتقرا منه بعدين."}},
            {"title": {"en": "Decide the courier's fee", "ar": "حدّد أجرة المندوب"},
             "body": {"en": "<strong>Pay the courier for this trip</strong> - yes, the courier keeps their delivery "
                            "fee (they drove); no, it is reversed off their balance. A failed delivery that "
                            "was the courier's fault is the case for no.",
                      "ar": "<strong>ادفع للمندوب أجر الرحلة دي</strong> — أيوه، المندوب ياخد أجرته (هو مشي "
                            "فعلًا)؛ لأ، بتتشال من حسابه. والتوصيل اللي فشل بسبب المندوب هو حالة \"لأ\"."}},
            {"title": {"en": "Decide the customer's money", "ar": "حدّد فلوس العميل"},
             "body": {"en": "<strong>Keep as customer credit</strong> or <strong>Refund cash now</strong>. If cash goes "
                            "back, hand it over before you confirm.",
                      "ar": "<strong>تفضل رصيد للعميل</strong> أو <strong>ارجع الفلوس دلوقتي</strong>. ولو كاش "
                            "راجع، سلّمه قبل ما تأكد."}},
        ]),
        ("call", "warn",
         {"en": "A full return is final", "ar": "المرتجع الكامل نهائي"},
         {"en": "A fully returned order moves to the <strong>Returned</strong> column and locks - nothing moves it "
                "again, by anyone. Be sure before you confirm a full return.",
          "ar": "الطلب اللي رجع بالكامل بينتقل لعمود <strong>مرتجع بالكامل</strong> وبيتقفل — مفيش حد "
                "بيحركه تاني. اتأكد قبل ما تأكد مرتجع كامل."}),

        ("h", {"en": "Custom shipping approvals", "ar": "اعتماد الشحن المخصص"}, "shipping"),
        ("p", {"en": "When staff use <strong>Request Custom Shipping</strong>, the order stops moving until you "
                     "answer. Menu &rarr; <strong>Manager Dashboard</strong> &rarr; <strong>Pending Custom Shipping "
                     "Approvals</strong> lists them with the current shipping, the requested amount and the reason.",
               "ar": "لما الموظف يستخدم <strong>طلب شحن مخصص</strong>، الطلب بيقف لحد ما ترد. المنيو &rarr; "
                     "<strong>لوحة تحكم المدير</strong> &rarr; <strong>طلبات الشحن المخصص المعلقة</strong> بتعرضهم "
                     "بالشحن الحالي والمبلغ المطلوب والسبب."}),
        ("bul", [
            {"en": "<strong>Approve</strong> applies the requested amount and lets the order go out.",
             "ar": "<strong>الموافقة</strong> بتطبّق المبلغ المطلوب وبتخلي الطلب يقدر يخرج."},
            {"en": "<strong>Reject</strong> takes an optional reason - write one, the person who asked will read it.",
             "ar": "<strong>الرفض</strong> بياخد سبب اختياري — اكتبه، اللي طلب هيقراه."},
            {"en": "Answer these first thing. Every pending request is an order sitting still.",
             "ar": "رد عليهم أول حاجة. كل طلب معلق ده طلب واقف مكانه."},
        ]),

        ("h", {"en": "Watching and closing shifts", "ar": "متابعة وقفل الورديات"}, "shifts"),
        ("p", {"en": "Menu &rarr; <strong>Shift Monitor</strong>. Filter by today, last 7 days or a custom range, by "
                     "branch and by open/closed. The summary counts open shifts, closed shifts, and how many "
                     "had a discrepancy.",
               "ar": "المنيو &rarr; <strong>متابعة شيفتات نقاط البيع</strong>. فلتر بالنهاردة أو آخر ٧ أيام أو "
                     "فترة مخصصة، وبالفرع، وبمفتوح/مغلق. والملخص بيعد الورديات المفتوحة والمغلقة وكام "
                     "واحدة فيها فرق."}),
        ("p", {"en": "<strong>Close This Shift</strong> closes a shift somebody else left open - the classic case "
                     "being a staff member who went home without closing.",
               "ar": "<strong>إقفال هذه الوردية</strong> بيقفل وردية حد تاني سابها مفتوحة — والحالة الكلاسيكية "
                     "هي موظف مشي من غير ما يقفل."}),
        ("steps", [
            {"title": {"en": "Count the drawer yourself", "ar": "عدّ الدرج بنفسك"},
             "body": {"en": "Enter the cash actually in the drawer. Any difference posts a cash over/short "
                            "entry exactly as a normal close would - you are not hiding anything by closing it.",
                      "ar": "اكتب الكاش الموجود فعلًا في الدرج. أي فرق هيتسجل في حساب العجز/الزيادة زي "
                            "الإقفال العادي بالظبط — إنت مش بتخبّي حاجة بالإقفال."}},
            {"title": {"en": "Give a reason - it is required", "ar": "اكتب السبب — مطلوب"},
             "body": {"en": "\"Staff member left without closing\" is a fine reason. An empty one is not accepted.",
                      "ar": "\"الموظف مشي من غير ما يقفل\" سبب كويس. والسبب الفاضي مش هيتقبل."}},
            {"title": {"en": "Read the courier warning", "ar": "اقرا تحذير المناديب"},
             "body": {"en": "If the branch still has unsettled courier transactions, the dialog says so and "
                            "makes you tick <em>\"I understand and want to close anyway\"</em>. Those balances stay "
                            "outstanding - closing does not clear them, and somebody still has to settle them.",
                      "ar": "لو الفرع لسه عنده معاملات مناديب مش مسواة، الشاشة هتقولك وهتخليك تعلّم على "
                            "<em>\"أنا فاهم وعايز أقفل برضه\"</em>. الأرصدة دي بتفضل مفتوحة — الإقفال مش "
                            "بيصفّيها، ولسه حد لازم يسوّيها."}},
        ]),

        ("h", {"en": "The rest of your menu", "ar": "باقي المنيو بتاعك"}, "menu"),
        ("tbl",
         [{"en": "Entry", "ar": "الاختيار"}, {"en": "What it is for", "ar": "بتستخدمه في إيه"}],
         [
             [{"en": "Master Orders", "ar": "جميع الطلبات"},
              {"en": "Every order across branches, searchable by order number or customer, filterable by "
                     "status, branch, payment and date. Use it when a customer calls about an order that is "
                     "no longer on today's board.",
               "ar": "كل الطلبات على مستوى الفروع، بحث برقم الطلب أو العميل، وفلترة بالحالة والفرع "
                     "والدفع والتاريخ. استخدمها لما عميل يتصل بخصوص طلب مش على بورد النهاردة."}],
             [{"en": "Manager Dashboard", "ar": "لوحة تحكم المدير"},
              {"en": "Recent orders, branch cash balances, and the custom shipping approvals above. You can "
                     "also reassign an order to another branch from here.",
               "ar": "أحدث الطلبات وأرصدة الفروع النقدية واعتمادات الشحن المخصص اللي فوق. وتقدر كمان "
                     "تنقل طلب لفرع تاني من هنا."}],
             [{"en": "Live courier map", "ar": "خريطة المناديب"},
              {"en": "Where your couriers are right now. Supervisors only - a courier can see their own run, "
                     "never a colleague's.",
               "ar": "المناديب بتوعك فين دلوقتي. للمشرفين بس — المندوب بيشوف خط سيره هو، عمره ما بيشوف "
                     "خط زميله."}],
             [{"en": "Change collection method", "ar": "تغيير طريقة التحصيل"},
              {"en": "On the order card. The customer paid differently than the order says - fix it here "
                     "rather than letting the courier balance drift. It only shows while that order's "
                     "courier balance is still open, and never on pickups, returns or partner orders. "
                     "Online methods need a reference number.",
               "ar": "على كارت الطلب. العميل دفع بطريقة غير المكتوبة — صلّحها هنا بدل ما حساب المندوب "
                     "يختل. وبتظهر بس طول ما رصيد المندوب على الطلب لسه مفتوح، ومش بتظهر خالص على "
                     "طلبات الاستلام ولا المرتجعات ولا طلبات الشركاء. والطرق الأونلاين محتاجة رقم مرجع."}],
             [{"en": "Mute an order alarm", "ar": "كتم تنبيه الطلب"},
              {"en": "You are one of the few roles that can. Use it sparingly - a muted branch is a branch "
                     "that misses orders.",
               "ar": "إنت من الأدوار القليلة اللي تقدر. استخدمها بحساب — الفرع المكتوم فرع بيفوّت طلبات."}],
         ]),

        ("h", {"en": "What is not yours", "ar": "اللي مش بتاعك"}, "limits"),
        ("p", {"en": "A line manager is a narrower manager, not a smaller owner. These sit above you, and "
                     "some of them still appear in your menu and will answer \"Not permitted\" - that is "
                     "expected, not a fault:",
               "ar": "مدير الخط مدير أضيق، مش مالك أصغر. الحاجات دي فوقك، وبعضها لسه بيظهر في المنيو "
                     "بتاعك وهيرد عليك \"غير مسموح\" — وده طبيعي مش عطل:"}),
        ("bul", [
            {"en": "<strong>Approving expenses</strong> - JARZ Manager only. You submit like everyone else.",
             "ar": "<strong>اعتماد المصاريف</strong> — JARZ Manager بس. إنت بتقدّم زيك زي أي حد."},
            {"en": "<strong>Manager Pricing in POS</strong> and editing price lists - manager tier.",
             "ar": "<strong>تسعير المدير</strong> في نقطة البيع وتعديل قوائم الأسعار — للمدير الأعلى."},
            {"en": "<strong>Cash Transfer, Purchase Invoice, Stock Transfer, Inventory Count</strong> - they may "
                   "show in the menu; the server refuses them.",
             "ar": "<strong>تحويل نقدية، فاتورة مشتريات، تحويل مخزني، جرد</strong> — ممكن يظهروا في المنيو؛ "
                   "بس السيرفر بيرفضهم."},
            {"en": "<strong>Reports</strong> - the analytics dashboards are manager tier. Materials &amp; "
                   "Consumables is the one you can open.",
             "ar": "<strong>التقارير</strong> — لوحات التحليلات للمدير الأعلى. تقرير الخامات والمستهلكات هو "
                   "اللي تقدر تفتحه."},
            {"en": "<strong>Reviewing and rejecting other people's item requests</strong> - you can raise them, "
                   "purchasing closes them.",
             "ar": "<strong>مراجعة ورفض طلبات الأصناف بتاعة غيرك</strong> — إنت تقدر تطلب، والمشتريات "
                   "هي اللي بتقفل."},
        ]),
    ],
}
