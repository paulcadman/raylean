class FamilyDef {α : Type u} (Fam : α → Type v) (a : α) (β : semiOutParam $ Type v) : Prop where
  family_key_eq_type : Fam a = β
