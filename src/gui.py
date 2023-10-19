import tkinter as tk
from tkinter import ttk
from tkinter import filedialog as fd
from tkinter.messagebox import showinfo
import item
import recommender


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
        self.root.geometry('300x600')
    
        self.selected_items = []
        self.tk_selected_items = tk.Variable(value=[])
        self.unselected_items = []
        self.tk_unselected_items = tk.Variable(value=[])
        
        self.setup_widgets()

    def update_recommendation_rankings(self):
        new_rankings = recommender.rank(self.item_list, self.selected_items)
        self.unselected_items = new_rankings
        tk_entries = []
        for item in self.unselected_items:
            tk_entries.append(f"{item.name} ({recommender.score(self.selected_items + [item])})")
        self.tk_unselected_items.set(value=tk_entries)

    def update_selection_rankings(self):
        tk_entries = []
        for item in self.selected_items:
            tk_entries.append(f"{item.name} ({recommender.score(self.selected_items)})") # need to score selected items
        self.tk_selected_items.set(value=tk_entries)
        
        
    def selected_item(self, event):
        index = self.recommended_listbox.curselection()[0]

        item = self.unselected_items.pop(index)
        self.selected_items.append(item)

        self.update_recommendation_rankings()
        self.update_selection_rankings()
        
    def setup_widgets(self):
        button_frame = ttk.Frame(
            self.root,
            relief=tk.RAISED,
            borderwidth=1)
        button_frame.pack(side=tk.TOP, fill=tk.X, expand=False)
        
        self.offers_button = ttk.Button(
            button_frame,
            text="Load Offers",
            command=self.load_offers)
        self.offers_button.pack(side=tk.TOP, fill=tk.BOTH, expand=True)

        self.needs_button = ttk.Button(
            button_frame,
            text="Load Needs",
            command=self.load_needs)
        self.needs_button.pack(side=tk.TOP, fill=tk.BOTH, expand=True)

        main_frame = ttk.Frame(
            self.root,
            relief=tk.RAISED,
            borderwidth=1)
        main_frame.pack(fill=tk.BOTH, expand=True)

        left_frame = ttk.LabelFrame(
            main_frame,
            text="Ranked Choices",
            relief=tk.RAISED,
            borderwidth=1)
        left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        right_frame = ttk.LabelFrame(
            main_frame,
            text="Selected",
            relief=tk.RAISED,
            borderwidth=1)
        right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

        self.recommended_listbox = tk.Listbox(
            left_frame,
            height=30,
            listvariable=self.tk_unselected_items,
            selectmode=tk.SINGLE)
        self.recommended_listbox.pack(side=tk.BOTTOM, fill=tk.BOTH, expand=True)
        self.recommended_listbox.bind("<<ListboxSelect>>", self.selected_item)

        self.selected_listbox = tk.Listbox(
            right_frame,
            height=30,
            listvariable=self.tk_selected_items,
            selectmode=tk.SINGLE)
        self.selected_listbox.pack(side=tk.BOTTOM, fill=tk.BOTH, expand=True)

    def load_offers(self):
        path = select_file("Select offers file")
        self.item_list = item.load_csv_offers(path, self.item_list)
        self.unselected_items = self.item_list
        self.update_recommendation_rankings()
        self.update_selection_rankings()
        self.offers_button.pack_forget()

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
