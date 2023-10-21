import tkinter as tk
from tkinter import ttk
from tkinter import filedialog as fd
from tkinter.messagebox import showinfo
import item
import recommender
import application


def select_file(title="Open a file"):
    return fd.askopenfilename(
        title=title,
        initialdir=".",
        filetypes=(('csv files', '*.csv'),)
    )

class Application:
    def __init__(self):
        self.item_list = []

        self.root = tk.Tk()
        self.root.title("Synergy Finder")
        self.root.resizable(False, False)
        self.root.geometry('600x600')
        self.offers_path = tk.StringVar()
        self.needs_path = tk.StringVar()

        self.application = None
        self.unselected_items = tk.Variable(value=[])
        self.selected_items = tk.Variable(value=[])

        self.setup_load_panel()
        #self.setup_widgets()

    def update_recommendation_rankings(self):
        new_rankings = recommender.rank(self.item_list, self.selected_items)
        self.unselected_items = new_rankings
        tk_entries = []
        for item in self.unselected_items:
            tk_entries.append(f"{item.name} ({recommender.score(self.selected_items + [item])})")
        self.unselected_items.set(value=tk_entries)

    def update_selection_rankings(self):
        tk_entries = []
        for item in self.selected_items:
            tk_entries.append(f"{item.name} ({recommender.score(self.selected_items)})") # need to score selected items
        self.selected_items.set(value=tk_entries)
        
        
    def selected_item(self, event):
        index = self.unselected_listbox.curselection()[0]

        item = self.unselected_items.pop(index)
        self.selected_items.append(item)

        self.update_recommendation_rankings()
        self.update_selection_rankings()

    def setup_load_panel(self):
        frame = ttk.Frame(self.root,relief=tk.RAISED, borderwidth=1)
        frame.pack(fill=tk.BOTH, expand=False)
        
        needs_frame = ttk.Frame(frame)
        needs_frame.pack(expand=True)

        needs_label = ttk.Label(needs_frame, textvariable = self.needs_path)
        needs_label.pack(side=tk.LEFT, fill=tk.X, expand=True)

        self.needs_button = ttk.Button(
            needs_frame,
            text="Choose Needs CSV File",
            command=lambda: self.needs_path.set(select_file("Select needs file")))
        self.needs_button.pack(side=tk.RIGHT, expand=False)

        offers_frame = ttk.Frame(frame)
        offers_frame.pack(expand=True)

        offers_label = ttk.Label(offers_frame, textvariable = self.offers_path)
        offers_label.pack(side=tk.LEFT, fill=tk.X, expand=True)

        offers_button = ttk.Button(
            offers_frame,
            text="Choose Offers CSV File",
            command=lambda: self.offers_path.set(select_file("Select offers file")))
        offers_button.pack(side=tk.RIGHT, expand=False)

        def load_application():
            if not (self.offers_path.get() and self.needs_path.get()):
                return
            frame.pack_forget()
            self.application = application.Application(
                offers_path=self.offers_path.get(),
                needs_path=self.needs_path.get(),)
            self.setup_selection_lists()

        load_app_button = ttk.Button(
            frame,
            text="Load Data",
            command=load_application)
        load_app_button.pack(side=tk.BOTTOM, expand=True)
            
        
    def setup_selection_lists(self):

        left_frame = ttk.LabelFrame(
            self.root,
            text="Unselected",
            relief=tk.RAISED,
            borderwidth=1)
        left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.right_frame = ttk.LabelFrame(
            self.root,
            text="Selected",
            relief=tk.RAISED,
            borderwidth=1)
        self.right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

        def selected_item(_event):
            selection = self.unselected_listbox.curselection()
            if selection:
                index = selection[0]
                self.application.select(index)
                self.update_rankings()

        self.unselected_listbox = tk.Listbox(
            left_frame,
            height=30,
            listvariable=self.unselected_items,
            selectmode=tk.SINGLE)
        self.unselected_listbox.pack(side=tk.BOTTOM, fill=tk.BOTH, expand=True)
        self.unselected_listbox.bind("<<ListboxSelect>>", selected_item)

        def unselected_item(_event):
            selection = self.selected_listbox.curselection()
            if selection:
                index = selection[0]
                self.application.unselect(index)
                self.update_rankings()

        self.selected_listbox = tk.Listbox(
            self.right_frame,
            height=30,
            listvariable=self.selected_items,
            selectmode=tk.SINGLE)
        self.selected_listbox.pack(side=tk.BOTTOM, fill=tk.BOTH, expand=True)
        self.selected_listbox.bind("<<ListboxSelect>>", unselected_item)

        self.update_rankings()

    def update_rankings(self):
        self.application.sort_unselected()
        unselected_list = []
        for item in self.application.unselected:
            unselected_list.append(f"{item.name} (+{recommender.score_margin(item, self.application.selected)})")
        self.unselected_items.set(unselected_list)

        self.application.sort_selected()
        selected_list = []
        for item in self.application.selected:
            other_selected = [i for i in self.application.selected if i!=item]
            selected_list.append(f"{item.name} (-{recommender.score_margin(item, other_selected)})")
        self.selected_items.set(selected_list)

        self.right_frame.configure(text = f"Selected ({recommender.score_selection(self.application.selected)} synergy points)")

    
    def load_needs(self):
        path = select_file("Select needs file")
        self.item_list = item.load_csv_needs(path, self.item_list)
        self.unselected_items = self.item_list
        self.update_recommendation_rankings()
        self.update_selection_rankings()
        self.needs_button.pack_forget()

    def run(self):
        self.root.mainloop()
    
if __name__ == "__main__":
    app = Application()
    app.run()
