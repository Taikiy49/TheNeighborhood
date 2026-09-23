--!strict
export type PlayerProfile = {Version: number, Currency: number, Inventory: {string}, Incidents: {any}, TutorialState: string}
export type ItemState = "Stored" | "Displayed" | "Carried" | "Escaped" | "Fenced" | "Sold"
export type ItemInstance = {Id: string, DefinitionId: string, OwnerUserId: number, OriginalOwnerUserId: number, State: ItemState, HolderUserId: number?, HouseId: string?, Slot: number?, Provenance: {any}}
export type EvidenceRecord = {Kind: string, Time: number, Description: string, Quality: string}
export type IncidentRecord = {Id: string, Time: number, HouseId: string, ItemName: string, Evidence: {EvidenceRecord}, Status: string}
return {}
