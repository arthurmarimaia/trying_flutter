import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/pet_controller.dart';
import '../services/locale_controller.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final s = context.watch<LocaleController>().s;
    final dailyItems = controller.dailyShopItemIds
        .map((id) => controller.storeItems.firstWhere(
              (i) => i.id == id,
              orElse: () => controller.storeItems.first,
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.storeTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: const Text('💰', style: TextStyle(fontSize: 14)),
              label: Text('${controller.pet.coins}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // ── Ofertas do Dia ──────────────────────────────────────────────
          if (dailyItems.isNotEmpty) ...[
            Row(
              children: [
                const Text('🔥 ', style: TextStyle(fontSize: 18)),
                Text(
                  s.storeDailyOffers,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  context.watch<LocaleController>().isPt ? 'Renova à meia-noite' : 'Resets at midnight',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dailyItems.length,
                separatorBuilder: (_, idx) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final item = dailyItems[i];
                  final discountedPrice = (item.price * 0.8).round();
                  final owned = controller.ownedItems[item.id] ?? false;
                  final canAfford = controller.pet.coins >= discountedPrice;
                  return _DailyOfferCard(
                    item: item,
                    discountedPrice: discountedPrice,
                    owned: owned,
                    canAfford: canAfford,
                    onBuy: () async {
                      // Temporarily override price via standard buyItem flow
                      // We apply the discount by crediting back the difference
                      final diff = item.price - discountedPrice;
                      await controller.buyItem(item.id);
                      if (diff > 0 && (controller.ownedItems[item.id] ?? false)) {
                        // Already granted via buyItem; give back discount diff
                        // (buyItem deducted full price; credit back difference)
                        controller.pet.coins =
                            (controller.pet.coins + diff).clamp(0, 999);
                        controller.saveState(notify: true);
                      }
                    },
                  );
                },
              ),
            ),
            const Divider(height: 28),
            Text(
              s.storeAllItems,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],
          // ── Lista completa ──────────────────────────────────────────────
          ...List.generate(controller.storeItems.length, (index) {
            final item = controller.storeItems[index];
            final owned = controller.ownedItems[item.id] ?? false;
            final isEquipped = controller.selectedAccessory == item.id;
            final canAfford = controller.pet.coins >= item.price;
            final inInventory = controller.inventoryCount(item.id);
            final atMaxStack = item.maxStack > 0 && inInventory >= item.maxStack;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StoreCard(
                item: item,
                owned: owned,
                isEquipped: isEquipped,
                canAfford: canAfford,
                inInventory: inInventory,
                atMaxStack: atMaxStack,
                onBuy: () => controller.buyItem(item.id),
                onEquip: () => controller.equipAccessory(item.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── _DailyOfferCard ──────────────────────────────────────────────────────────

class _DailyOfferCard extends StatelessWidget {
  final dynamic item;
  final int discountedPrice;
  final bool owned;
  final bool canAfford;
  final VoidCallback onBuy;

  const _DailyOfferCard({
    required this.item,
    required this.discountedPrice,
    required this.owned,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: owned
                        ? Colors.amber.shade100
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(item.icon, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.watch<LocaleController>().s.storeItemName(item.id),
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (!owned) ...[
                    Text(
                      '${item.price} 💰',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                    ),
                    Text(
                      '$discountedPrice 💰',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ] else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Builder(builder: (ctx) => Text(
                          ctx.watch<LocaleController>().s.storeOwned,
                          style: const TextStyle(fontSize: 11, color: Colors.green))),
                      ],
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          minimumSize: const Size(0, 28),
                          textStyle: const TextStyle(fontSize: 12)),
                      onPressed: owned || !canAfford ? null : onBuy,
                      child: Text(owned
                          ? context.watch<LocaleController>().s.storeOwned
                          : canAfford
                              ? context.watch<LocaleController>().s.storeBuy
                              : context.watch<LocaleController>().s.storeNotEnough),
                    ),
                  ),
                ],
              ),
            ),
            // Discount badge
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '−20%',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _StoreCard ───────────────────────────────────────────────────────────────

class _StoreCard extends StatelessWidget {
  final dynamic item;
  final bool owned;
  final bool isEquipped;
  final bool canAfford;
  final int inInventory;
  final bool atMaxStack;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  const _StoreCard({
    required this.item,
    required this.owned,
    required this.isEquipped,
    required this.canAfford,
    required this.inInventory,
    required this.atMaxStack,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: owned || inInventory > 0
                      ? Colors.amber.shade100
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Text(item.icon, style: const TextStyle(fontSize: 24)),
                ),
                if (inInventory > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade700,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '$inInventory',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.watch<LocaleController>().s.storeItemName(item.id),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(context.watch<LocaleController>().s.storeItemDescription(item.id)),
                  const SizedBox(height: 8),
                  if (!item.isCosmetic && item.maxStack > 0)
                    Text(
                        '${item.price} 💰  \u2022  ${context.watch<LocaleController>().isPt ? 'máx.' : 'max.'} ${item.maxStack} ${context.watch<LocaleController>().isPt ? 'no inventário' : 'in inventory'}',
                        style: Theme.of(context).textTheme.labelMedium)
                  else if (!owned)
                    Text('${context.watch<LocaleController>().isPt ? 'Preço' : 'Price'}: ${item.price} 💰',
                        style: Theme.of(context).textTheme.labelLarge)
                  else
                    Row(children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(context.watch<LocaleController>().s.storeOwned,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.green)),
                    ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (item.isCosmetic) ...[
              if (isEquipped)
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(context.watch<LocaleController>().s.storeEquipped),
                )
              else if (owned)
                ElevatedButton(
                  onPressed: onEquip,
                  child: Text(context.watch<LocaleController>().s.storeEquip),
                )
              else
                ElevatedButton(
                  onPressed: canAfford ? onBuy : null,
                  child: Text('${item.price} 💰'),
                ),
            ] else ...[
              ElevatedButton(
                onPressed: canAfford && !atMaxStack ? onBuy : null,
                child: atMaxStack
                    ? Text(context.watch<LocaleController>().isPt ? 'Cheio' : 'Full')
                    : canAfford
                        ? Text(context.watch<LocaleController>().s.storeBuy)
                        : Text(context.watch<LocaleController>().s.storeNotEnough),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
