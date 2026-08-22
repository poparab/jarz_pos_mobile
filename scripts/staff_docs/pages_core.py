# -*- coding: utf-8 -*-
"""Guide pages: start here, sign in, shift, taking an order.

Every string is a {"en": ..., "ar": ...} pair so the two language trees are
generated from one source and cannot drift. Arabic is Egyptian colloquial
(masri) on purpose - this is read on the floor, not in a boardroom.

UI labels quoted here are the real strings from ``lib/l10n/app_en.arb`` /
``app_ar.arb``; when a label changes there, change it here too.
"""

INDEX = {
    "key": "index",
    "icon": "&#128075;",
    "title": {"en": "Staff & Line Manager Guide", "ar": "دليل الموظفين ومديري الخطوط"},
    "hero": {"en": "Start here", "ar": "ابدأ من هنا"},
    "sub": {
        "en": "Everything a branch staff member or a line manager needs to run a day on Jarz POS - "
              "sign in, open a shift, take orders, move them on the board, settle the courier, close out.",
        "ar": "كل اللي محتاجه موظف الفرع أو مدير الخط عشان يشتغل يومه على جارز POS — الدخول، "
              "فتح الوردية، عمل الطلبات، تحريكها على البورد، تسوية المندوب، وقفل اليوم.",
    },
    "roles": ["staff", "line"],
    "blocks": [
        ("call", "info",
         {"en": "This guide covers two roles only", "ar": "الدليل ده بيغطي دورين بس"},
         {"en": "Staff (Jarz POS Staff) and line manager (JARZ line manager). Owner, accounting, "
                "B2B sales, production and purchasing screens are deliberately left out - if a "
                "menu entry is not described here, it is not part of your job.",
          "ar": "الموظف (Jarz POS Staff) ومدير الخط (JARZ line manager). شاشات المالك والحسابات "
                "والمبيعات B2B والإنتاج والمشتريات مش هنا بقصد — لو فيه حاجة في المنيو مش مشروحة "
                "هنا يبقى مش شغلك."}),

        ("h", {"en": "The day, end to end", "ar": "اليوم من أوله لآخره"}, "day"),
        ("flow", [
            {"en": "Sign in", "ar": "الدخول"},
            {"en": "Pick your branch", "ar": "اختار الفرع"},
            {"en": "Start Shift", "ar": "بدء الشيفت"},
            {"en": "Take orders", "ar": "خد الطلبات"},
            {"en": "Move them on the board", "ar": "حركهم على البورد"},
            {"en": "Settle couriers", "ar": "سوّي المناديب"},
            {"en": "End Shift", "ar": "إنهاء الشيفت"},
        ]),
        ("p", {"en": "The app will not let you skip a step: no order screen without an open shift, "
                     "and no shift close while a courier still owes money.",
               "ar": "التطبيق مش هيسيبك تعدي خطوة: مفيش شاشة طلبات من غير وردية مفتوحة، ومفيش قفل "
                     "وردية والمندوب لسه عليه فلوس."}),

        ("h", {"en": "Pick a topic", "ar": "اختار الموضوع"}, "topics"),
        ("cards", [
            {"href": "login.html", "icon": "&#128273;",
             "title": {"en": "1. Sign in", "ar": "١. الدخول"},
             "body": {"en": "Open the app, sign in, switch the app to Arabic, turn on order alerts, sign out.",
                      "ar": "تفتح التطبيق، تدخل، تحوّل اللغة للعربي، تشغّل تنبيهات الطلبات، وتخرج."}},
            {"href": "shift.html", "icon": "&#128340;",
             "title": {"en": "2. Shift", "ar": "٢. الوردية"},
             "body": {"en": "Open your shift with the counted cash, and close it at the end of the day.",
                      "ar": "تفتح ورديتك بالنقدية المعدودة، وتقفلها آخر اليوم."}},
            {"href": "pos.html", "icon": "&#128722;",
             "title": {"en": "3. Take an order", "ar": "٣. عمل طلب"},
             "body": {"en": "Customer first, then items, then pickup or a delivery slot, then Checkout.",
                      "ar": "العميل الأول، بعدين الأصناف، بعدين استلام أو ميعاد توصيل، وبعدين إتمام الطلب."}},
            {"href": "kanban.html", "icon": "&#128203;",
             "title": {"en": "4. Order board", "ar": "٤. بورد الطلبات"},
             "body": {"en": "Move an order stage by stage, send it out with a courier, collect the money.",
                      "ar": "تحرك الطلب مرحلة مرحلة، تبعته مع مندوب، وتحصّل الفلوس."}},
            {"href": "courier-balances.html", "icon": "&#9878;",
             "title": {"en": "5. Courier money", "ar": "٥. حساب المندوب"},
             "body": {"en": "See what each courier owes you or you owe them, and settle it.",
                      "ar": "تشوف كل مندوب له كام وعليه كام، وتسوّي معاه."}},
            {"href": "trips.html", "icon": "&#128666;",
             "title": {"en": "6. Trips", "ar": "٦. الرحلات"},
             "body": {"en": "Send several orders out with one courier as a single trip.",
                      "ar": "تبعت كذا طلب مع مندوب واحد في رحلة واحدة."}},
            {"href": "expenses.html", "icon": "&#128179;",
             "title": {"en": "7. Expenses & requests", "ar": "٧. المصاريف والطلبات"},
             "body": {"en": "Log money spent from the drawer, and ask for stock you are running out of.",
                      "ar": "تسجّل فلوس اتصرفت من الدرج، وتطلب بضاعة قربت تخلص."}},
            {"href": "line-manager.html", "icon": "&#127894;",
             "title": {"en": "8. Line manager extras", "ar": "٨. زيادات مدير الخط"},
             "body": {"en": "Cancel, return, approve custom shipping, watch shifts, close a shift someone left open.",
                      "ar": "الإلغاء والمرتجع واعتماد الشحن المخصص ومتابعة الورديات وقفل وردية حد نسيها مفتوحة."}},
        ]),

        ("h", {"en": "Which one am I?", "ar": "أنا مين فيهم؟"}, "roles"),
        ("p", {"en": "Open the menu and look at what is in it. Your role decides which entries exist, "
                     "and the guide marks every action with the role that can do it.",
               "ar": "افتح المنيو وبص على اللي فيه. دورك هو اللي بيحدد إيه اللي يظهر، والدليل بيعلّم "
                     "كل إجراء بالدور اللي يقدر يعمله."}),
        ("tbl",
         [{"en": "You are...", "ar": "إنت..."},
          {"en": "The app opens on", "ar": "التطبيق بيفتح على"},
          {"en": "Extra menu entries", "ar": "زيادات في المنيو"}],
         [
             [{"en": "Staff", "ar": "موظف"},
              {"en": "Sales Kanban (the order board)", "ar": "كانبان المبيعات (بورد الطلبات)"},
              {"en": "None - POS, board, trips, courier balances, expenses, item requests",
               "ar": "ولا حاجة — نقطة البيع، البورد، الرحلات، أرصدة المناديب، المصاريف، طلبات الأصناف"}],
             [{"en": "Line manager", "ar": "مدير خط"},
              {"en": "Point of Sale", "ar": "نقطة البيع"},
              {"en": "Master Orders, Manager Dashboard, Shift Monitor, Live courier map, "
                     "plus Cancel and Return on the order card",
               "ar": "جميع الطلبات، لوحة تحكم المدير، متابعة الورديات، خريطة المناديب، "
                     "وكمان إلغاء ومرتجع على كارت الطلب"}],
         ]),

        ("h", {"en": "Two things worth knowing before you start", "ar": "حاجتين اعرفهم قبل ما تبدأ"}, "basics"),
        ("bul", [
            {"en": "<strong>The app speaks Arabic.</strong> Menu &rarr; <strong>Language</strong> switches the "
                   "whole app between English and Arabic. This guide has the same page in both, "
                   "and the button in the header of every page switches it.",
             "ar": "<strong>التطبيق بيتكلم عربي.</strong> المنيو &rarr; <strong>اللغة</strong> بيحوّل التطبيق كله "
                   "بين العربي والإنجليزي. والدليل ده نفس الصفحات باللغتين، والزرار اللي فوق بيبدّل."},
            {"en": "<strong>Everything is per branch.</strong> The branch you pick at the top of POS or "
                   "the board (the POS profile) decides which orders you see, which stock you sell "
                   "from, and which cash drawer your shift belongs to.",
             "ar": "<strong>كل حاجة بالفرع.</strong> الفرع اللي بتختاره فوق في نقطة البيع أو البورد (ملف "
                   "نقطة البيع) هو اللي بيحدد الطلبات اللي تشوفها، والمخزن اللي بتبيع منه، ودرج "
                   "الكاش اللي ورديتك عليه."},
        ]),

        ("faq", [
            {"q": {"en": "A menu entry is missing compared to my colleague",
                   "ar": "فيه حاجة في المنيو عند زميلي ومش عندي"},
             "a": {"en": "The menu is built from your roles. If you need an entry you do not have, "
                         "ask your manager to change your role - it is not a setting on the device.",
                   "ar": "المنيو بتتبني من أدوارك. لو محتاج حاجة مش عندك، كلّم مديرك يغيّر دورك — "
                         "دي مش إعدادات على الموبايل."}},
            {"q": {"en": "Which version am I on?", "ar": "أنا على أي إصدار؟"},
             "a": {"en": "Menu &rarr; <strong>About</strong> shows the build, the environment and the patch "
                         "status. Have that screen open when you report a problem.",
                   "ar": "المنيو &rarr; <strong>حول التطبيق</strong> بيوريك الإصدار والبيئة وحالة التحديث. "
                         "افتح الشاشة دي وإنت بتبلّغ عن مشكلة."}},
        ]),
    ],
}


LOGIN = {
    "key": "login",
    "icon": "&#128273;",
    "title": {"en": "Sign in", "ar": "الدخول"},
    "hero": {"en": "Sign in", "ar": "الدخول"},
    "sub": {"en": "Opening the app, signing in, choosing your language, turning on order alerts, and signing out.",
            "ar": "تفتح التطبيق، تدخل بحسابك، تختار لغتك، تشغّل تنبيهات الطلبات، وتخرج."},
    "roles": ["staff", "line"],
    "blocks": [
        ("h", {"en": "Opening the app", "ar": "فتح التطبيق"}, "open"),
        ("bul", [
            {"en": "<strong>On the branch phone or tablet:</strong> open the <strong>Jarz POS</strong> app icon.",
             "ar": "<strong>على موبايل أو تابلت الفرع:</strong> افتح أيقونة <strong>Jarz POS</strong>."},
            {"en": "<strong>On a computer:</strong> open <code>erp.orderjarz.com/pos/</code> in Chrome.",
             "ar": "<strong>على الكمبيوتر:</strong> افتح <code>erp.orderjarz.com/pos/</code> في كروم."},
            {"en": "<strong>Installing the app on a new phone:</strong> open <code>erp.orderjarz.com/pos/download/</code> "
                   "and install from there. Ask your manager before installing on a personal phone.",
             "ar": "<strong>تنزيل التطبيق على موبايل جديد:</strong> افتح <code>erp.orderjarz.com/pos/download/</code> "
                   "ونزّل من هناك. اسأل مديرك الأول قبل ما تنزّله على موبايلك الشخصي."},
        ]),

        ("h", {"en": "Signing in", "ar": "تسجيل الدخول"}, "signin"),
        ("steps", [
            {"title": {"en": "Type your username", "ar": "اكتب اسم المستخدم"},
             "body": {"en": "The <strong>Username</strong> field takes the account your manager created for you. "
                            "It is usually your work email.",
                      "ar": "خانة <strong>اسم المستخدم</strong> بتاخد الحساب اللي مديرك عمله ليك. "
                            "غالبًا بيكون إيميل الشغل."}},
            {"title": {"en": "Type your password", "ar": "اكتب كلمة المرور"},
             "body": {"en": "Tap the eye icon to check what you typed before you submit.",
                      "ar": "دوس على علامة العين عشان تتأكد من اللي كتبته قبل ما تبعت."}},
            {"title": {"en": "Tap Login", "ar": "دوس تسجيل الدخول"},
             "body": {"en": "Staff land on the <strong>Sales Kanban</strong>; line managers land on "
                            "<strong>Point of Sale</strong>. Both can move between the two from the menu.",
                      "ar": "الموظف بينزل على <strong>كانبان المبيعات</strong>، ومدير الخط بينزل على "
                            "<strong>نقطة البيع</strong>. والاتنين يقدروا يتنقلوا بينهم من المنيو."}},
        ]),
        ("call", "info",
         {"en": "You stay signed in", "ar": "بتفضل داخل"},
         {"en": "You do not sign in again every morning. The app remembers you until you sign out, or "
                "until you close a shift - closing a shift signs you out on purpose, so the next person "
                "starts on their own account.",
          "ar": "مش هتسجل دخول كل يوم الصبح. التطبيق فاكرك لحد ما تخرج بنفسك، أو لحد ما تقفل وردية — "
                "قفل الوردية بيطلّعك بقصد، عشان اللي بعدك يبدأ بحسابه هو."}),

        ("h", {"en": "Switching the app to Arabic", "ar": "تحويل التطبيق للعربي"}, "language"),
        ("steps", [
            {"title": {"en": "Open the menu", "ar": "افتح المنيو"},
             "body": {"en": "Tap the <strong>&#9776;</strong> icon in the header of POS or the order board. "
                            "The menu is grouped: POS / Sales, Delivery / Logistics, Finance / Expenses, "
                            "Purchasing / Inventory, and so on.",
                      "ar": "دوس على علامة <strong>&#9776;</strong> اللي فوق في نقطة البيع أو بورد الطلبات. "
                            "المنيو مقسومة مجموعات: نقطة البيع/المبيعات، التوصيل/اللوجستيات، المالية/"
                            "المصروفات، المشتريات/المخزون، وهكذا."}},
            {"title": {"en": "Scroll to the bottom", "ar": "انزل لتحت خالص"},
             "body": {"en": "Below every menu group there is a <strong>Language</strong> switch showing the "
                            "language you are on now.",
                      "ar": "تحت كل مجموعات المنيو هتلاقي مفتاح <strong>اللغة</strong> ومكتوب عليه اللغة "
                            "اللي إنت عليها دلوقتي."}},
            {"title": {"en": "Flip it and confirm", "ar": "حوّله وأكّد"},
             "body": {"en": "The app asks \"Switch language to Arabic?\". Confirm and the whole app flips, "
                            "right to left included. Nothing about your orders changes.",
                      "ar": "التطبيق هيسألك \"تحويل اللغة إلى العربية؟\". أكّد وهيتقلب التطبيق كله، "
                            "وكمان الاتجاه من اليمين للشمال. مفيش حاجة بتتغير في طلباتك."}},
        ]),

        ("h", {"en": "Turning on order alerts", "ar": "تشغيل تنبيهات الطلبات"}, "alerts"),
        ("p", {"en": "When a new online order arrives, the app rings an alarm and shows the order on top "
                     "of whatever you are doing, with an <strong>Accept Order</strong> button. Accepting it moves "
                     "the order onto the board and stops the alarm.",
               "ar": "لما يجيلك طلب أونلاين جديد، التطبيق بيرن ويطلعلك الطلب فوق أي حاجة إنت فيها، "
                     "وعليه زرار <strong>قبول الطلب</strong>. أول ما تقبله الطلب بينزل على البورد والتنبيه بيقف."}),
        ("bul", [
            {"en": "The settings live on the <strong>Profile</strong> screen: open the order board and tap "
                   "<strong>&#8942;</strong> (More Actions) in the header &rarr; <strong>Profile</strong>. It is not in "
                   "the side menu. There you pick the alarm sound and see the roles you hold.",
             "ar": "الإعدادات في شاشة <strong>الملف الشخصي</strong>: افتح بورد الطلبات ودوس على "
                   "<strong>&#8942;</strong> (المزيد) اللي فوق &rarr; <strong>الملف الشخصي</strong>. مش موجودة في "
                   "المنيو الجانبي. هناك بتختار صوت التنبيه وبتشوف الأدوار اللي معاك."},
            {"en": "<strong>On an iPhone using the web app:</strong> add the page to the Home Screen first, "
                   "open it from there, then tap <strong>Enable Notifications</strong> on that Profile screen. "
                   "Alerts will not arrive in a normal Safari tab.",
             "ar": "<strong>على الآيفون بنسخة الويب:</strong> ضيف الصفحة للشاشة الرئيسية الأول، افتحها "
                   "من هناك، وبعدين دوس <strong>فعّل الإشعارات</strong> في شاشة الملف الشخصي دي. التنبيهات "
                   "مش هتوصل من تاب سفاري عادي."},
            {"en": "<strong>Only a line manager or above can mute the alarm.</strong> Staff can lower the "
                   "handset volume but the mute switch is not theirs.",
             "ar": "<strong>مدير الخط وفوق بس هم اللي يقدروا يكتموا التنبيه.</strong> الموظف يقدر ينزّل صوت "
                   "الموبايل بس مفتاح الكتم مش بتاعه."},
        ]),

        ("h", {"en": "Signing out", "ar": "الخروج"}, "signout"),
        ("p", {"en": "Menu &rarr; <strong>Logout</strong>. Do this before handing the device to someone else - "
                     "every order, shift and settlement is recorded against whoever is signed in.",
               "ar": "المنيو &rarr; <strong>تسجيل الخروج</strong>. اعمل كده قبل ما تدّي الجهاز لحد تاني — كل "
                     "طلب ووردية وتسوية بتتسجل باسم اللي داخل بحسابه."}),

        ("h", {"en": "When it will not let you in", "ar": "لما ميرضاش يدخّلك"}, "trouble"),
        ("faq", [
            {"q": {"en": "\"Invalid credentials\"", "ar": "\"بيانات الاعتماد غير صحيحة\""},
             "a": {"en": "The username or password is wrong. Check the keyboard language and that Caps Lock "
                         "is off. Nobody at the branch can reset a password - ask your manager.",
                   "ar": "اسم المستخدم أو الباسورد غلط. راجع لغة الكيبورد وإن الحروف الكبيرة مش شغالة. "
                         "محدش في الفرع يقدر يغيّر الباسورد — كلّم مديرك."}},
            {"q": {"en": "\"Cannot reach server. Check Wi-Fi/VPN and backend URL, then try again.\"",
                   "ar": "\"تعذر الوصول إلى الخادم. تحقق من شبكة Wi-Fi أو الـ VPN وعنوان الخادم\""},
             "a": {"en": "This is the network, not your account. Check Wi-Fi, try mobile data, and try again. "
                         "If other branches are working too, report it - do not keep retrying for an hour.",
                   "ar": "دي مشكلة نت مش مشكلة حساب. راجع الواي فاي، جرّب بيانات الموبايل، وجرّب تاني. "
                         "ولو باقي الفروع شغالة، بلّغ — متفضلش تعيد المحاولة ساعة."}},
            {"q": {"en": "\"No POS Profiles Available\"", "ar": "\"لا توجد ملفات نقاط بيع متاحة\""},
             "a": {"en": "Your account is not attached to any branch yet. Your manager has to add you to "
                         "the branch's POS profile before you can sell anything.",
                   "ar": "حسابك لسه مش مربوط بأي فرع. المدير لازم يضيفك على ملف نقطة البيع بتاع الفرع "
                         "قبل ما تقدر تبيع."}},
        ]),
    ],
}


SHIFT = {
    "key": "shift",
    "icon": "&#128340;",
    "title": {"en": "Shift", "ar": "الوردية"},
    "hero": {"en": "Opening and closing your shift", "ar": "فتح وقفل الوردية"},
    "sub": {"en": "A shift ties every order and every pound you handle to you and to one branch drawer. "
                  "You open it before your first order and close it after your last.",
            "ar": "الوردية بتربط كل طلب وكل جنيه بيعدي من إيدك بيك وبدرج فرع واحد. بتفتحها قبل أول "
                  "طلب وبتقفلها بعد آخر طلب."},
    "roles": ["staff", "line"],
    "blocks": [
        ("call", "stop",
         {"en": "No shift, no POS", "ar": "مفيش وردية، مفيش بيع"},
         {"en": "The app sends you to <strong>Start Shift</strong> and keeps you there until there is an open "
                "shift on the branch you selected <em>that you opened yourself</em>. A colleague's open shift "
                "does not count, and neither does your own shift on a different branch.",
          "ar": "التطبيق هيوديك على <strong>بدء الشيفت</strong> ومش هيسيبك تخرج منها غير لما يبقى فيه وردية "
                "مفتوحة على الفرع اللي اخترته <em>وإنت اللي فاتحها</em>. وردية زميلك مش بتحسب، وكمان "
                "ورديتك إنت على فرع تاني مش بتحسب."}),

        ("h", {"en": "Opening your shift", "ar": "فتح الوردية"}, "open"),
        ("steps", [
            {"title": {"en": "Pick the branch first", "ar": "اختار الفرع الأول"},
             "body": {"en": "The <strong>Select POS Profile</strong> screen (or the branch name in the header) "
                            "decides which drawer the shift belongs to. Picking the wrong branch here is the "
                            "single most common cause of a shift that will not close.",
                      "ar": "شاشة <strong>اختر ملف نقطة البيع</strong> (أو اسم الفرع اللي فوق) هي اللي بتحدد "
                            "الدرج اللي الوردية عليه. اختيار فرع غلط هنا هو أكتر سبب لوردية مش راضية تتقفل."}},
            {"title": {"en": "Count the cash in the drawer", "ar": "عدّ الكاش اللي في الدرج"},
             "body": {"en": "The screen says <em>\"Count opening cash and enter it\"</em> and shows the branch, the "
                            "cash account and the <strong>System Balance</strong> - what the system thinks is in "
                            "there. Count the real money anyway.",
                      "ar": "الشاشة بتقول <em>\"قم بعدّ نقدية البداية ثم أدخلها\"</em> وبتوريك الفرع والحساب "
                            "النقدي و<strong>الرصيد بالنظام</strong> — اللي النظام فاكر إنه موجود. برضه عدّ "
                            "الفلوس الحقيقية."}},
            {"title": {"en": "Enter what you counted", "ar": "اكتب اللي عدّيته"},
             "body": {"en": "Type the counted amount into <strong>Counted Opening Cash</strong>. The app shows the "
                            "<strong>Difference</strong> against the system balance as you type. Enter the real "
                            "number even when it does not match - that is the whole point of counting.",
                      "ar": "اكتب المبلغ اللي عدّيته في <strong>النقدية المعدودة عند البداية</strong>. التطبيق "
                            "هيوريك <strong>الفرق</strong> مع رصيد النظام وإنت بتكتب. اكتب الرقم الحقيقي حتى لو "
                            "مش مظبوط — ده أصلًا سبب إنك بتعد."}},
            {"title": {"en": "Tap Start Shift", "ar": "دوس بدء الشيفت"},
             "body": {"en": "You land on the order screen and the header shows <strong>Shift Active</strong> with the "
                            "time you started.",
                      "ar": "هتنزل على شاشة الطلبات وفوق هيبان <strong>شيفت مفتوح</strong> ومعاه وقت البداية."}},
        ]),
        ("call", "warn",
         {"en": "Cash only", "ar": "كاش بس"},
         {"en": "Count the physical cash for this branch and nothing else. InstaPay, wallet and card money "
                "is tracked by the system on its own - you never type those in at shift start.",
          "ar": "عدّ الكاش الحقيقي بتاع الفرع ده وبس. إنستاباي والمحفظة والفيزا النظام بيتابعهم لوحده — "
                "إنت عمرك ما بتكتبهم في بداية الوردية."}),

        ("h", {"en": "Closing your shift", "ar": "قفل الوردية"}, "close"),
        ("steps", [
            {"title": {"en": "Clear the board first", "ar": "صفّي البورد الأول"},
             "body": {"en": "Every order for the day should be in its right column, and every payment recorded. "
                            "An order left in the middle of the board is a question somebody has to answer tomorrow.",
                      "ar": "كل طلبات اليوم لازم تكون في عمودها الصح، وكل دفعة اتسجلت. أي طلب سايب في نص "
                            "البورد ده سؤال حد هيرد عليه بكرة."}},
            {"title": {"en": "Settle your couriers", "ar": "سوّي مع المناديب"},
             "body": {"en": "If a courier still owes the branch (or the branch owes them), the app blocks the "
                            "close - see below.",
                      "ar": "لو لسه مندوب عليه فلوس للفرع (أو الفرع عليه فلوس ليه)، التطبيق هيوقف القفل — "
                            "شوف تحت."}},
            {"title": {"en": "Open End Shift", "ar": "افتح إنهاء الشيفت"},
             "body": {"en": "Menu &rarr; <strong>End Shift</strong>. The entry only appears when the open shift on the "
                            "selected branch is yours.",
                      "ar": "المنيو &rarr; <strong>إنهاء الشيفت</strong>. الاختيار ده بيظهر بس لما الوردية المفتوحة "
                            "على الفرع المختار تكون بتاعتك."}},
            {"title": {"en": "Count the drawer and enter it", "ar": "عدّ الدرج واكتبه"},
             "body": {"en": "The screen says <em>\"Count the cash in the drawer and enter the amount\"</em> and shows "
                            "nothing else - no expected total, no difference. That is deliberate: you count what "
                            "is actually there, then the system compares.",
                      "ar": "الشاشة بتقول <em>\"قم بعدّ النقدية في الدرج ثم أدخل المبلغ\"</em> ومش بتوريك أي حاجة "
                            "تانية — لا المتوقع ولا الفرق. ده بقصد: إنت بتعد اللي موجود فعلًا، والنظام هو اللي "
                            "بيقارن بعدين."}},
            {"title": {"en": "Tap End Shift", "ar": "دوس إنهاء الشيفت"},
             "body": {"en": "Now the summary appears: expected, counted, and the difference per payment method, "
                            "plus the invoice count and the day's totals. If there is a difference, the system posts "
                            "a cash over/short entry by itself - you do not adjust anything.",
                      "ar": "دلوقتي بيظهر الملخص: المتوقع والمعدود والفرق لكل وسيلة دفع، وكمان عدد الفواتير "
                            "وإجماليات اليوم. ولو فيه فرق، النظام بيسجل قيد زيادة/عجز لوحده — إنت مش بتظبط حاجة."}},
            {"title": {"en": "You are signed out", "ar": "هيطلّعك برّه"},
             "body": {"en": "Closing the shift signs you out on purpose, so the next person on the device starts "
                            "on their own account.",
                      "ar": "قفل الوردية بيطلّعك من الحساب بقصد، عشان اللي هياخد الجهاز بعديك يبدأ بحسابه هو."}},
        ]),

        ("h", {"en": "\"Settle courier balances before ending the shift\"",
               "ar": "\"سوِّ أرصدة المندوبين قبل إنهاء الشيفت\""}, "courier-block"),
        ("p", {"en": "This is the most common thing that stops a close. The message names how many courier "
                     "transactions are still open, across how many couriers and how many orders, and it lists "
                     "each courier with their net balance.",
               "ar": "دي أكتر حاجة بتوقف القفل. الرسالة بتقولك فيه كام حركة مندوب لسه مفتوحة، وعلى كام "
                     "مندوب وكام طلب، وبتعدد كل مندوب وصافي رصيده."}),
        ("p", {"en": "Tap <strong>Review &amp; Settle Couriers</strong>, settle what is pending, then come back and "
                     "close. Settling couriers is part of the staff job - you do not need a manager for it.",
               "ar": "دوس <strong>مراجعة وتسوية المندوبين</strong>، سوّي اللي معلّق، وبعدين ارجع اقفل. تسوية "
                     "المناديب دي شغل الموظف — مش محتاج مدير عشانها."}),
        ("call", "info",
         {"en": "Full details", "ar": "التفاصيل كاملة"},
         {"en": "How to read the balances and settle them is on the [Courier money](courier-balances.html) page.",
          "ar": "طريقة قراءة الأرصدة وتسويتها موجودة في صفحة [حساب المندوب](courier-balances.html)."}),

        ("h", {"en": "When it will not open or close", "ar": "لما ميرضاش يفتح أو يقفل"}, "trouble"),
        ("faq", [
            {"q": {"en": "\"Shift Already Open\" - started by someone else",
                   "ar": "\"الشيفت مفتوح بالفعل\" — حد تاني فاتحه"},
             "a": {"en": "The branch already has an open shift started by another user, and it must be closed "
                         "before a new one starts. If that person has gone home, a line manager can close it "
                         "from Shift Monitor.",
                   "ar": "الفرع فيه وردية مفتوحة بدأها حد تاني، ولازم تتقفل قبل ما تبدأ وردية جديدة. ولو "
                         "الشخص ده مشي، مدير الخط يقدر يقفلها من متابعة الورديات."}},
            {"q": {"en": "\"You have an open shift on profile X\"",
                   "ar": "\"لديك شيفت مفتوح على ملف كذا\""},
             "a": {"en": "You left a shift open on another branch. Use <strong>Switch to active shift profile</strong> "
                         "then <strong>Go to End Shift</strong>, close it, and come back. You can only hold one open "
                         "shift at a time.",
                   "ar": "إنت سايب وردية مفتوحة على فرع تاني. استخدم <strong>التبديل لملف الشيفت المفتوح</strong> "
                         "وبعدين <strong>اذهب إلى إنهاء الشيفت</strong>، اقفلها، وارجع. مينفعش يبقى معاك أكتر "
                         "من وردية مفتوحة."}},
            {"q": {"en": "\"Cash entry is unavailable\"", "ar": "\"تعذر إظهار حقل إدخال النقدية\""},
             "a": {"en": "The shift has no closing payment method configured, so there is nothing to count "
                         "against. Reopen the shift or contact support - this is a setup problem, not something "
                         "you can fix at the branch.",
                   "ar": "الوردية مفيهاش وسيلة دفع للإقفال، فمفيش حاجة تتعدّ أصلًا. اعد فتح الوردية أو كلّم "
                         "الدعم — دي مشكلة إعدادات مش حاجة تتظبط من الفرع."}},
            {"q": {"en": "I counted wrong and already closed", "ar": "عدّيت غلط وقفلت خلاص"},
             "a": {"en": "Tell your line manager the same day. The difference is already posted as a cash "
                         "over/short entry; correcting it is an accounting job, not a re-count.",
                   "ar": "قول لمدير الخط في نفس اليوم. الفرق اتسجل خلاص كقيد زيادة/عجز؛ تصحيحه شغل "
                         "حسابات مش إعادة عد."}},
        ]),
    ],
}


POS = {
    "key": "pos",
    "icon": "&#128722;",
    "title": {"en": "Taking an order", "ar": "عمل طلب"},
    "hero": {"en": "Taking an order", "ar": "عمل طلب"},
    "sub": {"en": "Customer first, then items, then how it reaches them, then Checkout. "
                  "The order appears on the board the moment you submit it.",
            "ar": "العميل الأول، بعدين الأصناف، بعدين هيوصله إزاي، وبعدين إتمام الطلب. "
                  "الطلب بيظهر على البورد أول ما تبعته."},
    "roles": ["staff", "line"],
    "blocks": [
        ("call", "info",
         {"en": "The order is fixed", "ar": "الترتيب ثابت"},
         {"en": "The item grid stays locked until a customer is chosen - it will say "
                "<em>\"Please select a customer first\"</em>. This is on purpose: the customer decides the "
                "price list, the delivery fee and the branch.",
          "ar": "شبكة الأصناف بتفضل مقفولة لحد ما تختار عميل — هيقولك <em>\"يرجى اختيار عميل أولاً\"</em>. "
                "ده بقصد: العميل هو اللي بيحدد قائمة الأسعار ورسوم التوصيل والفرع."}),

        ("h", {"en": "1. Choose the customer", "ar": "١. اختار العميل"}, "customer"),
        ("steps", [
            {"title": {"en": "Search by phone first", "ar": "دوّر بالتليفون الأول"},
             "body": {"en": "Phone is the reliable way to find a repeat customer - names get typed differently "
                            "every time. Switch to name search only if the phone finds nothing.",
                      "ar": "التليفون هو الطريقة المضمونة إنك تلاقي عميل قديم — الأسامي بتتكتب بألف شكل. "
                            "حوّل للبحث بالاسم بس لو التليفون مجابش حاجة."}},
            {"title": {"en": "If they are new, create them", "ar": "لو جديد، اعمله"},
             "body": {"en": "<strong>Create Customer</strong> takes the name, the type (Individual or Company) and "
                            "the customer group. Take a second to get the phone right - it is how you will find "
                            "them next time.",
                      "ar": "<strong>إنشاء عميل</strong> بياخد الاسم والنوع (فرد أو شركة) ومجموعة العميل. خد "
                            "ثانية وظبّط التليفون صح — ده اللي هتلاقيه بيه المرة الجاية."}},
            {"title": {"en": "Pick the delivery address", "ar": "اختار عنوان التوصيل"},
             "body": {"en": "<strong>Choose Shipping Address</strong> lists the addresses already saved for that "
                            "customer, or lets you add one. The <strong>Territory</strong> on the address is what "
                            "sets the delivery fee, so pick it properly.",
                      "ar": "<strong>اختر عنوان الشحن</strong> بيوريك العناوين المحفوظة للعميل، أو تضيف واحد "
                            "جديد. <strong>المنطقة</strong> اللي على العنوان هي اللي بتحدد رسوم التوصيل، "
                            "فاختارها صح."}},
        ]),
        ("call", "warn",
         {"en": "\"Profile Mismatch\"", "ar": "\"عدم تطابق الفرع\""},
         {"en": "If the customer's territory belongs to another branch, the app asks whether to keep your "
                "branch or switch to the territory's branch. Switch unless you have a reason not to - the "
                "branch that owns the territory is the one that can actually deliver there.",
          "ar": "لو منطقة العميل تبع فرع تاني، التطبيق هيسألك تفضل على فرعك ولا تحوّل لفرع المنطقة. "
                "حوّل إلا لو عندك سبب — الفرع بتاع المنطقة هو اللي يقدر يوصّل هناك فعلًا."}),

        ("h", {"en": "2. Add the items", "ar": "٢. ضيف الأصناف"}, "items"),
        ("bul", [
            {"en": "Tap a card to add one. The card shows <strong>In cart</strong> with the quantity already "
                   "added, so you can see at a glance what is in the order.",
             "ar": "دوس على الكارت عشان تضيف واحد. الكارت بيوريك <strong>في السلة</strong> والكمية اللي "
                   "اتضافت، فتقدر تشوف بنظرة الطلب فيه إيه."},
            {"en": "<strong>Bundles</strong> have their own tab. Opening a bundle lets you pick what goes inside "
                   "it; <strong>Edit Bundle</strong> in the cart reopens that choice.",
             "ar": "<strong>الباقات</strong> ليها تاب لوحدها. لما تفتح باقة بتختار اللي جواها؛ و<strong>تعديل "
                   "الباقة</strong> من السلة بيفتحلك الاختيار تاني."},
            {"en": "<strong>Out of stock</strong> and <em>\"Stock limit reached. Only N available\"</em> mean the system "
                   "has none left. You can still finish the order, but somebody has to actually find the goods.",
             "ar": "<strong>نفدت الكمية</strong> و<em>\"تم الوصول لحد المخزون. المتوفر كذا فقط\"</em> معناهم إن "
                   "النظام مش شايف رصيد. لسه تقدر تكمّل الطلب، بس حد لازم يجيب البضاعة فعلًا."},
        ]),

        ("h", {"en": "3. Pickup or delivery", "ar": "٣. استلام ولا توصيل"}, "delivery"),
        ("bul", [
            {"en": "<strong>Pickup (no delivery fee)</strong> - the customer collects from the branch. No slot, no "
                   "courier, no delivery charge, and the order never needs a settlement.",
             "ar": "<strong>استلام من الفرع (بدون رسوم توصيل)</strong> — العميل هيجي ياخد الطلب. مفيش ميعاد "
                   "ولا مندوب ولا رسوم توصيل، والطلب ده عمره ما هيحتاج تسوية."},
            {"en": "<strong>Delivery</strong> - you must pick a <strong>Delivery Time</strong> slot. The first available "
                   "slot is marked <strong>Next</strong>.",
             "ar": "<strong>التوصيل</strong> — لازم تختار <strong>وقت التوصيل</strong>. أول ميعاد متاح عليه "
                   "علامة <strong>التالي</strong>."},
        ]),
        ("call", "warn",
         {"en": "A slot that has passed is refused", "ar": "الميعاد اللي عدّى بيترفض"},
         {"en": "The app will not let you submit onto a slot whose time is already gone. If the list looks "
                "short late in the day, that is why - pick the next real slot and tell the customer.",
          "ar": "التطبيق مش هيسيبك تبعت على ميعاد وقته عدّى. لو القايمة باينة قليلة آخر اليوم، ده السبب — "
                "اختار أول ميعاد حقيقي وقول للعميل."}),

        ("h", {"en": "4. Check the cart", "ar": "٤. راجع السلة"}, "cart"),
        ("tbl",
         [{"en": "Line", "ar": "السطر"}, {"en": "What it is", "ar": "معناه"}],
         [
             [{"en": "Subtotal", "ar": "الإجمالي الفرعي"},
              {"en": "The goods, before delivery.", "ar": "قيمة البضاعة قبل التوصيل."}],
             [{"en": "Delivery", "ar": "التوصيل"},
              {"en": "The delivery charged to the customer. Comes from the address territory.",
               "ar": "التوصيل اللي بيتحسب على العميل. بييجي من منطقة العنوان."}],
             [{"en": "Promo code", "ar": "كود الخصم"},
              {"en": "Type a code and it shows <strong>Applied</strong> or <strong>Not eligible</strong>. "
                     "\"Not eligible\" is the code's own rules - it is not a fault.",
               "ar": "اكتب الكود وهيبان عليه <strong>اتطبق</strong> أو <strong>مش مؤهل</strong>. "
                     "\"مش مؤهل\" دي شروط الكود نفسه — مش عطل."}],
             [{"en": "Total", "ar": "الإجمالي"},
              {"en": "What the customer pays.", "ar": "اللي العميل هيدفعه."}],
             [{"en": "Operational Info", "ar": "معلومات تشغيلية"},
              {"en": "<strong>Delivery Expense</strong> - what the delivery costs the branch. This is your cost, "
                     "not the customer's price.",
               "ar": "<strong>تكلفة التوصيل</strong> — التوصيل مكلف الفرع كام. دي تكلفتك إنت، مش سعر العميل."}],
         ]),
        ("call", "manager",
         {"en": "Manager pricing", "ar": "تسعير المدير"},
         {"en": "The <strong>Manager Pricing</strong> panel - price list, order purpose, zero shipping, a custom "
                "delivery amount, per-line discounts - is manager-tier only. Line managers do not get it "
                "either; a line manager who needs a different delivery charge on a live order requests it "
                "from the board instead.",
          "ar": "لوحة <strong>تسعير المدير</strong> — قائمة الأسعار وغرض الطلب وإلغاء الشحن ومبلغ توصيل مخصص "
                "وخصومات السطر — دي للمدير الأعلى بس. حتى مدير الخط مش بياخدها؛ ولو مدير الخط محتاج "
                "توصيل مختلف على طلب شغال، بيطلبه من البورد."}),

        ("h", {"en": "5. Checkout", "ar": "٥. إتمام الطلب"}, "checkout"),
        ("steps", [
            {"title": {"en": "Tap Checkout", "ar": "دوس إتمام الطلب"},
             "body": {"en": "If anything in the cart is over the system's stock, a warning lists each line - "
                            "<em>requested N, available M</em>. <strong>Proceed with order</strong> creates it anyway.",
                      "ar": "لو أي حاجة في السلة أكتر من رصيد النظام، هيطلعلك تحذير بكل سطر — "
                            "<em>المطلوب كذا، المتاح كذا</em>. و<strong>متابعة الطلب</strong> بيعمله برضه."}},
            {"title": {"en": "Confirm", "ar": "أكّد"},
             "body": {"en": "<em>\"Order placed successfully!\"</em> means it is on the board, in the "
                            "<strong>Received</strong> column, ready for the kitchen.",
                      "ar": "<em>\"تم إرسال الطلب بنجاح!\"</em> معناها إنه على البورد، في عمود "
                            "<strong>مستلم</strong>، جاهز للمطبخ."}},
        ]),
        ("call", "info",
         {"en": "Payment is not taken here", "ar": "الدفع مش بيتاخد هنا"},
         {"en": "A delivery order is created unpaid on purpose. The money is recorded on the board when the "
                "order goes out or comes back settled - see the [Order board](kanban.html#ofd) page.",
          "ar": "طلب التوصيل بيتعمل غير مدفوع بقصد. الفلوس بتتسجل على البورد وقت ما الطلب يخرج أو يرجع "
                "متسوّي — شوف صفحة [بورد الطلبات](kanban.html#ofd)."}),

        ("h", {"en": "Parking an order", "ar": "تعليق طلب"}, "drafts"),
        ("p", {"en": "A half-built cart can be saved as a draft and picked up later - useful when a customer "
                     "is still deciding and there is a queue behind them. There is a limit; if you hit "
                     "<em>\"Draft limit reached\"</em>, delete an old draft you no longer need.",
               "ar": "تقدر تحفظ سلة نص جاهزة كمسودة وترجعلها بعدين — مفيدة لما عميل لسه بيفكر وفيه طابور "
                     "وراه. فيه حد أقصى؛ ولو طلعلك <em>\"تم الوصول إلى الحد الأقصى للمسودات\"</em>، امسح "
                     "مسودة قديمة مش محتاجها."}),

        ("h", {"en": "When something goes wrong", "ar": "لما حاجة تبوظ"}, "trouble"),
        ("faq", [
            {"q": {"en": "The item grid is empty", "ar": "شبكة الأصناف فاضية"},
             "a": {"en": "Either no customer is selected, or the category filter is on something with nothing "
                         "in it. Tap <strong>All</strong> first.",
                   "ar": "يا إما مفيش عميل مختار، يا إما الفلتر واقف على تصنيف مفيهوش حاجة. دوس "
                         "<strong>الكل</strong> الأول."}},
            {"q": {"en": "\"Bundle contents could not be loaded\"",
                   "ar": "\"محتويات الباقة مش قادرة تتحمّل\""},
             "a": {"en": "Do not submit. Open <strong>Edit Bundle</strong>, reselect the items, and try again - "
                         "submitting a bundle the app could not read produces an order nobody can fulfil.",
                   "ar": "متبعتش. افتح <strong>تعديل الباقة</strong>، اختار الأصناف تاني، وحاول تاني — لو "
                         "بعتّ باقة التطبيق مقدرش يقراها هيطلع طلب محدش هيعرف يجهزه."}},
            {"q": {"en": "\"No delivery slots available\"", "ar": "\"لا توجد مواعيد توصيل متاحة\""},
             "a": {"en": "Either the branch timetable is not set up, or every slot for today has passed. "
                         "Check the branch is right; if it is, this is a setup issue for your manager.",
                   "ar": "يا إما جدول مواعيد الفرع مش متظبط، يا إما كل مواعيد النهاردة عدّت. اتأكد إن "
                         "الفرع صح؛ ولو صح، دي مشكلة إعدادات لمديرك."}},
            {"q": {"en": "I submitted the wrong order", "ar": "بعتّ الطلب غلط"},
             "a": {"en": "Do not create a second one. Find it on the board: <strong>Edit Invoice</strong> changes "
                         "what is in it, and a line manager can cancel it outright.",
                   "ar": "متعملش طلب تاني. لاقيه على البورد: <strong>تعديل الفاتورة</strong> بيغيّر اللي جواه، "
                         "ومدير الخط يقدر يلغيه خالص."}},
        ]),
    ],
}
